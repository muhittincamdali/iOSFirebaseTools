import Foundation

/// Turns path segments into text, replacing IDs and the value after a secret name with `:id`.
struct PathRedactor {
    private static let punctuation = Set("-_.~():!*,".unicodeScalars)
    private var hideNext = false

    /// The percent-encoded path of a URL, or `nil` when only scheme and host may be shown: dot
    /// segments, `;`, `%2E`, double encoding, a backslash or too many segments.
    static func renderURLPath(_ encodedPath: String) -> String? {
        guard !encodedPath.isEmpty else { return "" }
        let lowered = encodedPath.lowercased()
        guard !["; ", ";", "%3b", "%2e", "%25", "\\", "%5c"].contains(where: lowered.contains) else { return nil }
        let segments = encodedPath.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard segments.count <= Redaction.maxPathSegments, !segments.contains(where: { $0 == "." || $0 == ".." }) else {
            return nil
        }
        var redactor = PathRedactor()
        var rendered: [String] = []
        for segment in segments {
            guard let decoded = segment.removingPercentEncoding else { return nil }
            rendered.append(redactor.isHidden(decoded) ? Redaction.pathID : segment)
        }
        return rendered.joined(separator: "/")
    }

    /// Decoded segments, such as a Firestore document path.
    func render(_ segments: [String]) -> String {
        var redactor = self
        return segments.map { redactor.isHidden($0) ? Redaction.pathID : $0 }.joined(separator: "/")
    }

    /// Whether the segment is shown as `:id`. A segment that is not plain is a label: it is
    /// hidden, and so is the one after it. A secret name is shown and the next one hidden.
    private mutating func isHidden(_ segment: String) -> Bool {
        if hideNext {
            hideNext = false
            return true
        }
        if segment.isEmpty { return false }
        if Self.looksLikeIdentifier(segment) { return true }
        let scalars = segment.unicodeScalars
        guard scalars.allSatisfy({ $0.isASCII && ($0.properties.isAlphabetic || ("0"..."9").contains($0) || Self.punctuation.contains($0)) }) else {
            hideNext = true
            return true
        }
        let words = segment.split { !$0.isASCII || !($0.isLetter || $0.isNumber) }
        if words.contains(where: { Redaction.isSecretName(String($0)) }) { hideNext = true }
        return false
    }

    /// UUIDs, 6 or more digits, mixed tokens of 16 characters or more, anything a detector
    /// matches, and segments longer than 256 characters.
    static func looksLikeIdentifier(_ segment: String) -> Bool {
        let scalars = segment.unicodeScalars
        if scalars.count > Redaction.maxValueLength || UUID(uuidString: segment) != nil { return true }
        if scalars.filter({ ("0"..."9").contains($0) }).count >= 6 { return true }
        if scalars.count >= 16, scalars.allSatisfy({ $0.isASCII && ($0.properties.isAlphabetic || ("0"..."9").contains($0)) }) {
            let hasDigit = scalars.contains { ("0"..."9").contains($0) }
            let hasUpper = scalars.contains { ("A"..."Z").contains($0) }
            let hasLower = scalars.contains { ("a"..."z").contains($0) }
            if hasDigit || (hasUpper && hasLower) { return true }
        }
        return Detectors.matches(segment)
    }
}

/// Finds values that look like credentials or personal data in any text: e-mail addresses,
/// bearer tokens, JSON Web Tokens, long hex or base64 runs, card numbers (Luhn) and IBANs
/// (mod 97). Each check is one pass over the Unicode scalars.
enum Detectors {
    static let longTokenLength = 32
    private static let base64 = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=_-".unicodeScalars)
    // VT, FF, NEL, LS and PS join the ordinary separators, so a number split by them still matches.
    private static let separators = Set(" \t\n\r-\u{0B}\u{0C}\u{85}\u{2028}\u{2029}".unicodeScalars)

    static func matches(_ text: String) -> Bool {
        let scalars = Array(text.unicodeScalars)
        return hasEmail(scalars) || hasBearer(text) || hasJWT(scalars) || hasLongToken(scalars)
            || hasCardNumber(scalars) || hasIBAN(scalars)
    }

    private static func isWordScalar(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.properties.generalCategory {
        case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter, .modifierLetter, .otherLetter,
             .nonspacingMark, .spacingMark, .enclosingMark, .decimalNumber, .letterNumber, .otherNumber:
            true
        default:
            "._+-".unicodeScalars.contains(scalar)
        }
    }

    /// A local part of Unicode letters, marks, digits or `. _ + -`, `@`, and a domain.
    static func hasEmail(_ scalars: [Unicode.Scalar]) -> Bool {
        for (index, scalar) in scalars.enumerated() where scalar == "@" {
            guard index > 0, index + 1 < scalars.count else { continue }
            if isWordScalar(scalars[index - 1]) && isWordScalar(scalars[index + 1]) { return true }
        }
        return false
    }

    static func hasBearer(_ text: String) -> Bool {
        text.range(of: "bearer", options: [.caseInsensitive]) != nil
    }

    /// `eyJ…` followed by two more dot-separated base64url parts.
    static func hasJWT(_ scalars: [Unicode.Scalar]) -> Bool {
        var index = 0
        while index + 2 < scalars.count {
            guard scalars[index] == "e", scalars[index + 1] == "y", scalars[index + 2] == "J" else {
                index += 1
                continue
            }
            var dots = 0
            var end = index
            while end < scalars.count, base64.contains(scalars[end]) || scalars[end] == "." {
                if scalars[end] == "." { dots += 1 }
                end += 1
            }
            if dots >= 2 { return true }
            index = max(end, index + 1)
        }
        return false
    }

    /// 32 or more base64 or hex characters in a row, at least one of them a digit, so long
    /// words and media types such as `application/x-www-form-urlencoded` stay readable.
    static func hasLongToken(_ scalars: [Unicode.Scalar]) -> Bool {
        var run = 0
        var runHasDigit = false
        for scalar in scalars {
            if base64.contains(scalar) {
                run += 1
                runHasDigit = runHasDigit || ("0"..."9").contains(scalar)
            } else {
                run = 0
                runHasDigit = false
            }
            if run >= longTokenLength, runHasDigit { return true }
        }
        return false
    }

    private static func decimalDigit(_ scalar: Unicode.Scalar) -> Int? {
        guard scalar.properties.numericType == .decimal, let value = scalar.properties.numericValue else { return nil }
        return Int(value)
    }

    /// 13 to 19 digits, with single separators between them, that pass the Luhn check; or
    /// more than 19 digits in a row, which no card has but other identifiers do.
    static func hasCardNumber(_ scalars: [Unicode.Scalar]) -> Bool {
        var digits: [Int] = []
        var lastWasSeparator = false
        func endOfRun() -> Bool {
            defer { digits.removeAll(keepingCapacity: true) }
            if digits.count > 19 { return true }
            guard digits.count >= 13 else { return false }
            var sum = 0
            for (offset, digit) in digits.reversed().enumerated() {
                let value = offset % 2 == 1 ? digit * 2 : digit
                sum += value > 9 ? value - 9 : value
            }
            return sum % 10 == 0
        }
        for scalar in scalars {
            if let digit = decimalDigit(scalar) {
                digits.append(digit)
                lastWasSeparator = false
            } else if separators.contains(scalar), !lastWasSeparator, !digits.isEmpty {
                lastWasSeparator = true
            } else {
                if endOfRun() { return true }
                lastWasSeparator = false
            }
        }
        return endOfRun()
    }

    /// Two letters, two digits and 11 to 30 letters or digits whose mod-97 value is 1
    /// (ISO 13616), with separators ignored. Each start position reads at most 34 characters.
    static func hasIBAN(_ scalars: [Unicode.Scalar]) -> Bool {
        let compact = scalars.filter { !separators.contains($0) }.map { scalar in
            ("a"..."z").contains(scalar) ? Unicode.Scalar(UInt8(scalar.value - 32)) : scalar
        }
        // Letters count as 10 to 35 and digits as themselves.
        func value(_ scalar: Unicode.Scalar) -> Int? {
            if ("0"..."9").contains(scalar) { return Int(scalar.value - 48) }
            if ("A"..."Z").contains(scalar) { return Int(scalar.value - 55) }
            return nil
        }
        guard compact.count >= 15 else { return false }
        for start in 0...(compact.count - 15) {
            guard let first = value(compact[start]), let second = value(compact[start + 1]), first > 9, second > 9,
                  let check1 = value(compact[start + 2]), let check2 = value(compact[start + 3]), check1 < 10, check2 < 10
            else { continue }
            // The country code and check digits are moved behind the account part: six digits.
            let countryPart = (first * 100 + second) * 100 + check1 * 10 + check2
            var remainder = 0
            for (length, scalar) in compact[(start + 4)...].prefix(30).enumerated() {
                guard let digit = value(scalar) else { break }
                remainder = (digit > 9 ? remainder * 100 + digit : remainder * 10 + digit) % 97
                if length + 1 >= 11, (remainder * 1_000_000 + countryPart) % 97 == 1 { return true }
            }
        }
        return false
    }
}
