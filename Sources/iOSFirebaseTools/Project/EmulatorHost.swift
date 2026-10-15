import Foundation

/// The address of a service in the Firebase Local Emulator Suite, such as `127.0.0.1:9099`.
///
/// The format is the one the Firebase CLI prints and puts in `FIREBASE_AUTH_EMULATOR_HOST` and
/// `FIRESTORE_EMULATOR_HOST`: a host name, IPv4 address or bracketed IPv6 address, a colon and a
/// port. Anything else, such as a scheme, a path or a port outside 1–65535, is rejected so the
/// value cannot redirect requests to an unexpected URL.
public struct EmulatorHost: Sendable, Hashable, CustomStringConvertible {
    /// The host name or address, without brackets for IPv6.
    public let host: String
    /// The TCP port.
    public let port: Int

    /// Parses `host:port`.
    public init(_ address: String) throws {
        let invalid = { (reason: String) in ValidationError("emulator address \"\(address)\"", reason) }
        guard let colon = address.lastIndex(of: ":") else { throw invalid("expected host:port") }
        var hostPart = String(address[..<colon])
        let portPart = address[address.index(after: colon)...]
        if hostPart.hasPrefix("[") && hostPart.hasSuffix("]") {
            hostPart = String(hostPart.dropFirst().dropLast())
            guard Self.isIPv6(hostPart) else { throw invalid("not an IPv6 address") }
        } else {
            guard Self.isHostName(hostPart) else { throw invalid("not a host name or IPv4 address") }
        }
        guard portPart.count <= 5, portPart.allSatisfy(\.isASCIIDigit), let port = Int(portPart),
              (1...65_535).contains(port) else {
            throw invalid("the port must be a number from 1 to 65535")
        }
        self.host = hostPart
        self.port = port
        guard URL(string: "http://\(description)") != nil else { throw invalid("not a valid URL host") }
    }

    /// Creates an address from its parts.
    public init(host: String, port: Int) throws {
        let bracketed = host.contains(":") ? "[\(host)]" : host
        try self.init("\(bracketed):\(port)")
    }

    /// `host:port`, with brackets around an IPv6 address.
    public var description: String {
        host.contains(":") ? "[\(host)]:\(port)" : "\(host):\(port)"
    }

    /// `http://host:port`: the emulators do not use TLS.
    var baseURL: URL {
        // The initializer checked that this URL parses.
        URL(string: "http://\(description)")!
    }

    private static func isHostName(_ value: String) -> Bool {
        guard !value.isEmpty, value.utf8Count <= 253 else { return false }
        let labels = value.split(separator: ".", omittingEmptySubsequences: false)
        return labels.allSatisfy { label in
            !label.isEmpty && label.count <= 63 && !label.hasPrefix("-") && !label.hasSuffix("-")
                && label.allSatisfy { $0.isASCIILetterOrDigit || $0 == "-" }
        }
    }

    private static func isIPv6(_ value: String) -> Bool {
        // Hex digits, colons and dots only: no zone index ("%en0") or other text in the URL.
        guard !value.isEmpty, value.utf8Count <= 45, value.contains(":"),
              value.allSatisfy({ ($0.isHexDigit && $0.isASCII) || $0 == ":" || $0 == "." }) else { return false }
        var address = in6_addr()
        return inet_pton(AF_INET6, value, &address) == 1
    }
}

extension Character {
    var isASCIIDigit: Bool { isASCII && isNumber }
    var isASCIILetterOrDigit: Bool { isASCII && (isLetter || isNumber) }
}
