import Foundation

/// Which header and query values the text forms of ``HTTPRequest`` and ``HTTPResponse`` keep.
///
/// The text forms never show a body, a fragment or URL user info. Header values and query
/// values appear only for names on these lists; everything else is `<redacted>`. Names are
/// compared after folding case, `_`, `-`, `.` and spaces, and a name that is a secret name
/// (`authorization`, `token`, `key`, …) stays hidden even when it is listed.
public struct RedactionPolicy: Sendable, Hashable {
    /// `content-type`, `content-length`, `accept`, `user-agent`, `cache-control` and `etag`.
    public static let defaultAllowedHeaders: Set<String> = [
        "content-type", "content-length", "accept", "user-agent", "cache-control", "etag",
    ]

    /// The default: the headers in ``defaultAllowedHeaders`` and no query values.
    public static let `default` = RedactionPolicy()

    let allowedHeaders: Set<String>
    let allowedQueryParameters: Set<String>
    /// `true` writes URLs as scheme, host and port only.
    public let recordsHostOnly: Bool

    public init(allowedHeaders: Set<String> = defaultAllowedHeaders, allowedQueryParameters: Set<String> = [],
                recordsHostOnly: Bool = false) {
        self.allowedHeaders = Set(allowedHeaders.map(Redaction.fold))
        self.allowedQueryParameters = Set(allowedQueryParameters.map(Redaction.fold))
        self.recordsHostOnly = recordsHostOnly
    }
}

/// The text forms of values that may carry tokens, passwords or user data.
///
/// The rule is default-safe: what the code does not fully understand is hidden. Bodies are
/// never shown; URLs lose user info, fragment, query values and ID-like path segments; header
/// values are kept for an allowlist only.
enum Redaction {
    static let hidden = "<redacted>"
    static let pathID = ":id"
    static let unparsedURL = "<unparsed URL>"

    static let maxURLBytes = 8 * 1_024
    static let maxPathSegments = 32
    static let maxQueryItems = 32
    static let maxHeaders = 64
    static let maxValueLength = 256
    static let maxLabelLength = 120

    /// Secret names, folded: the shared list plus the Firebase request fields that carry
    /// credentials (`oobCode`, `postBody`, `pendingToken`, `sessionInfo`, `nonce`, …).
    static let secretNames: Set<String> = [
        "password", "passwd", "pwd", "secret", "token", "accesstoken", "refreshtoken", "idtoken", "apikey",
        "key", "auth", "authorization", "cookie", "setcookie", "session", "sid", "otp", "pin", "cvv", "card",
        "iban", "ssn", "privatekey", "clientsecret", "signature",
        "oobcode", "postbody", "pendingtoken", "sessioninfo", "nonce", "credential", "assertion", "bearer",
        "transaction", "pagetoken", "jwt",
    ]

    /// Fragments that make any header name secret.
    private static let secretHeaderParts = ["token", "secret", "key", "auth", "session", "signature", "cookie", "password"]

    // MARK: - Names

    /// Percent-decodes, applies NFKC, folds case, and drops `_`, `-`, `.` and spaces.
    static func fold(_ name: String) -> String {
        let decoded = name.removingPercentEncoding ?? name
        let folded = decoded.precomposedStringWithCompatibilityMapping.folding(options: .caseInsensitive, locale: nil)
        var scalars = String.UnicodeScalarView()
        for scalar in folded.unicodeScalars where !"_-. ".unicodeScalars.contains(scalar) {
            scalars.append(scalar)
        }
        return String(scalars)
    }

    /// Non-empty and only ASCII `a-z` and `0-9`.
    static func isPlain(_ folded: String) -> Bool {
        !folded.isEmpty && folded.unicodeScalars.allSatisfy { ("a"..."z").contains($0) || ("0"..."9").contains($0) }
    }

    /// The one decision for every name: a name that is not plain ASCII after folding, or that
    /// is on the secret list (plural included), is secret.
    static func isSecretName(_ name: String) -> Bool {
        let folded = fold(name)
        guard isPlain(folded) else { return true }
        return secretNames.contains(folded) || (folded.hasSuffix("s") && secretNames.contains(String(folded.dropLast())))
    }

    static func isSecretHeader(_ name: String) -> Bool {
        let folded = fold(name)
        return isSecretName(name) || secretHeaderParts.contains { folded.contains($0) }
    }

    // MARK: - Values

    /// Printable ASCII, at most ``maxValueLength`` characters, and no detector match.
    static func isClean(_ value: String) -> Bool {
        let scalars = value.unicodeScalars
        guard scalars.count <= maxValueLength,
              scalars.allSatisfy({ (0x20...0x7E).contains($0.value) }) else { return false }
        return !Detectors.matches(value)
    }

    /// The first 10 characters of a user ID followed by `…`, or ``hidden`` for an ID that is not
    /// clean.
    static func shortID(_ id: String) -> String {
        guard isClean(id) else { return hidden }
        return id.count > 10 ? "\(id.prefix(10))…" : id
    }

    private static let labelPunctuation = Set(" _.:/()[]+-".unicodeScalars)

    /// A value the developer passed or a token holds, echoed in an error: quoted when it is at
    /// most 120 ASCII letters, digits and ` _.:/()[]+-`, names no secret and matches no
    /// detector; otherwise hidden with its length. Escapes, `=`, quotes and line breaks all
    /// hide the value.
    static func label(_ value: String) -> String {
        let scalars = value.unicodeScalars
        let clean = scalars.count <= maxLabelLength
            && scalars.allSatisfy { $0.isASCII && ($0.properties.isAlphabetic || ("0"..."9").contains($0) || labelPunctuation.contains($0)) }
            && !words(value).contains(where: isSecretName)
            && !Detectors.matches(value)
        return clean ? "\"\(value)\"" : "<redacted, \(scalars.count) characters>"
    }

    /// Runs of ASCII letters and digits.
    static func words(_ text: String) -> [String] {
        var words: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in text.unicodeScalars {
            if scalar.isASCII, scalar.properties.isAlphabetic || ("0"..."9").contains(scalar) {
                current.append(scalar)
            } else if !current.isEmpty {
                words.append(String(current))
                current = String.UnicodeScalarView()
            }
        }
        if !current.isEmpty { words.append(String(current)) }
        return words
    }

    /// Splits on one Unicode scalar, keeping empty parts. Splitting on `Character` would merge
    /// a delimiter with a combining mark that follows it.
    static func split(_ text: String, on separator: Unicode.Scalar) -> [String] {
        var parts: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in text.unicodeScalars {
            if scalar == separator {
                parts.append(String(current))
                current = String.UnicodeScalarView()
            } else {
                current.append(scalar)
            }
        }
        parts.append(String(current))
        return parts
    }

    /// A Firestore path echoed in an error, with ID-like segments as `:id`.
    static func path(_ path: String) -> String {
        guard path.utf8.count <= maxURLBytes else { return "<redacted, \(path.utf8.count) bytes>" }
        let segments = split(path, on: "/")
        guard segments.count <= maxPathSegments * 4 else { return "<redacted, \(segments.count) segments>" }
        return "\"\(PathRedactor().render(segments))\""
    }

    // MARK: - HTTP

    static func method(_ method: String) -> String {
        let scalars = method.unicodeScalars
        return (1...16).contains(scalars.count) && scalars.allSatisfy({ ("A"..."Z").contains($0) }) ? method : hidden
    }

    static func headers(_ headers: [String: String], policy: RedactionPolicy) -> String {
        let entries = headers.map { name, value -> String in
            let lowered = name.lowercased()
            // Names pass the same checks as query names: a long or token-like name is hidden too.
            guard isPlain(fold(name)), isClean(name), lowered.unicodeScalars.allSatisfy({ (0x21...0x7E).contains($0.value) }) else {
                return "\(hidden): \(hidden)"
            }
            let keep = policy.allowedHeaders.contains(fold(name)) && !isSecretHeader(name) && isClean(value)
            return "\(lowered): \(keep ? value : hidden)"
        }.sorted()
        let shown = entries.prefix(maxHeaders).joined(separator: ", ")
        let rest = entries.count > maxHeaders ? ", +\(entries.count - maxHeaders) more" : ""
        return "[\(shown)\(rest)]"
    }

    static func body(_ body: Data?, headers: [String: String]) -> String {
        guard let body, !body.isEmpty else { return "none" }
        let contentType = headers.first { $0.key.lowercased() == "content-type" }?.value
        return "[body omitted: \(body.count) bytes, \(mediaType(contentType))]"
    }

    private static func mediaType(_ contentType: String?) -> String {
        guard let contentType else { return "no content type" }
        guard contentType.unicodeScalars.count <= 1_024 else { return "unknown content type" }
        let type = split(contentType, on: ";")[0].trimmingCharacters(in: .whitespaces).lowercased()
        let token = { (part: String) in
            !part.isEmpty && part.unicodeScalars.allSatisfy { ("a"..."z").contains($0) || ("0"..."9").contains($0) || "!#$&^_.+-".unicodeScalars.contains($0) }
        }
        let parts = split(type, on: "/")
        guard type.unicodeScalars.count <= 100, parts.count == 2, token(parts[0]), token(parts[1]) else { return "unknown content type" }
        return type
    }

    /// Scheme, host, port and path with ID-like segments as `:id`; query names with values on
    /// the allowlist only; never user info or the fragment.
    static func url(_ url: URL, policy: RedactionPolicy) -> String {
        guard url.absoluteString.utf8.count <= maxURLBytes,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(),
              scheme.unicodeScalars.allSatisfy({ ("a"..."z").contains($0) || ("0"..."9").contains($0) || "+.-".unicodeScalars.contains($0) })
        else { return unparsedURL }
        guard let host = components.percentEncodedHost, !host.isEmpty else { return "\(scheme):\(hidden)" }
        guard isHostName(host) else { return "\(scheme)://\(hidden)" }
        let origin = "\(scheme)://\(host.lowercased())" + (components.port.map { ":\($0)" } ?? "")
        // A host that names a secret (`myapp://pin/4831`) keeps nothing after it.
        if policy.recordsHostOnly || (!host.hasPrefix("[") && split(host, on: ".").contains(where: isSecretName)) {
            return origin
        }
        guard let path = PathRedactor.renderURLPath(components.percentEncodedPath) else { return origin }
        guard let items = components.percentEncodedQueryItems, !items.isEmpty else { return origin + path }
        guard items.count <= maxQueryItems else { return origin }
        let query = items.map { item -> String in
            let name = item.name.removingPercentEncoding ?? ""
            guard isPlain(fold(name)), isClean(name) else { return "\(hidden)=\(hidden)" }
            guard let value = item.value else { return name }
            let decoded = value.removingPercentEncoding ?? ""
            let keep = policy.allowedQueryParameters.contains(fold(name)) && !isSecretName(name) && isClean(decoded)
            return "\(name)=\(keep ? decoded : hidden)"
        }
        return origin + path + "?" + query.joined(separator: "&")
    }

    /// An LDH host name, an IPv4 address or a bracketed IPv6 address, with no detector match.
    private static func isHostName(_ host: String) -> Bool {
        let scalars = host.unicodeScalars
        guard scalars.count <= 253 else { return false }
        if host.hasPrefix("["), host.hasSuffix("]") {
            return scalars.dropFirst().dropLast().allSatisfy { $0.properties.isASCIIHexDigit || $0 == ":" || $0 == "." }
        }
        return scalars.allSatisfy { ("a"..."z").contains($0) || ("A"..."Z").contains($0) || ("0"..."9").contains($0) || $0 == "-" || $0 == "." }
            && !Detectors.matches(host)
    }
}
