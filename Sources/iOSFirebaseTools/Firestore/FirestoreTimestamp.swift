import Foundation

/// A point in time with Firestore's precision: seconds and nanoseconds since 1970, for the years
/// 0001 to 9999. Firestore stores microseconds and rounds anything finer down.
public struct FirestoreTimestamp: Sendable, Hashable, Comparable, Codable {
    public let seconds: Int64
    public let nanoseconds: Int32

    /// 0001-01-01T00:00:00Z.
    static let minSeconds: Int64 = -62_135_596_800
    /// 9999-12-31T23:59:59Z.
    static let maxSeconds: Int64 = 253_402_300_799

    public init(seconds: Int64, nanoseconds: Int32) throws {
        guard (Self.minSeconds...Self.maxSeconds).contains(seconds), (0..<1_000_000_000).contains(nanoseconds) else {
            throw ValidationError("timestamp", "outside 0001-01-01 to 9999-12-31, or nanoseconds outside 0–999999999")
        }
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }

    private enum CodingKeys: String, CodingKey {
        case seconds, nanoseconds
    }

    // Decoding goes through the range check, like every other way of making a timestamp.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            seconds: try container.decode(Int64.self, forKey: .seconds),
            nanoseconds: try container.decode(Int32.self, forKey: .nanoseconds)
        )
    }

    /// Converts a `Date`. Dates outside 0001–9999, and NaN or infinite dates, throw instead of
    /// trapping in the integer conversion.
    public init(_ date: Date) throws {
        let interval = date.timeIntervalSince1970
        guard interval.isFinite, interval >= Double(Self.minSeconds), interval < Double(Self.maxSeconds) + 1 else {
            throw ValidationError("timestamp", "the date is outside 0001-01-01 to 9999-12-31")
        }
        let whole = interval.rounded(.down)
        let nanos = min(((interval - whole) * 1_000_000_000).rounded(), 999_999_999)
        try self.init(seconds: Int64(whole), nanoseconds: Int32(nanos))
    }

    /// The timestamp as a `Date`. A `Date` is a `Double`, so nanoseconds may round.
    public var date: Date {
        Date(timeIntervalSince1970: Double(seconds) + Double(nanoseconds) / 1_000_000_000)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.seconds, lhs.nanoseconds) < (rhs.seconds, rhs.nanoseconds)
    }

    /// RFC 3339 in UTC with as many fractional digits as needed, the form the REST API sends.
    public var rfc3339: String {
        let days = Int(seconds.floorDivided(by: 86_400))
        let secondOfDay = Int(seconds - Int64(days) * 86_400)
        let (year, month, day) = Self.civilDate(fromDays: days)
        var text = String(format: "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day,
                          secondOfDay / 3_600, secondOfDay % 3_600 / 60, secondOfDay % 60)
        if nanoseconds > 0 {
            var fraction = String(format: "%09d", nanoseconds)
            while fraction.hasSuffix("0") { fraction.removeLast() }
            text += "." + fraction
        }
        return text + "Z"
    }

    /// Parses RFC 3339, `2026-10-15T08:41:00.123456Z` or with an offset such as `+03:00`.
    public init(rfc3339 text: String) throws {
        let invalid = ValidationError("timestamp \(Redaction.label(String(text.prefix(40))))", "not an RFC 3339 date and time")
        var parser = RFC3339Parser(text)
        guard let parsed = parser.parse(), (1...12).contains(parsed.month) else { throw invalid }
        let monthLength = Self.daysIn(month: parsed.month, year: parsed.year)
        guard (1...monthLength).contains(parsed.day), parsed.hour < 24, parsed.minute < 60, parsed.second < 60 else {
            throw invalid
        }
        let days = Int64(Self.days(fromCivilYear: parsed.year, month: parsed.month, day: parsed.day))
        let secondOfDay = Int64(parsed.hour * 3_600 + parsed.minute * 60 + parsed.second)
        let utc: Int64 = days * 86_400 + secondOfDay - Int64(parsed.offsetSeconds)
        try self.init(seconds: utc, nanoseconds: parsed.nanoseconds)
    }

    // Howard Hinnant's days_from_civil and civil_from_days, valid for the whole 0001–9999 range.
    static func days(fromCivilYear year: Int, month: Int, day: Int) -> Int {
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yearOfEra = y - era * 400
        let dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    static func civilDate(fromDays days: Int) -> (Int, Int, Int) {
        let z = days + 719_468
        let era = (z >= 0 ? z : z - 146_096) / 146_097
        let dayOfEra = z - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let mp = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * mp + 2) / 5 + 1
        let month = mp < 10 ? mp + 3 : mp - 9
        return (yearOfEra + era * 400 + (month <= 2 ? 1 : 0), month, day)
    }

    static func daysIn(month: Int, year: Int) -> Int {
        switch month {
        case 2: (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28
        case 4, 6, 9, 11: 30
        default: 31
        }
    }
}

private extension Int64 {
    func floorDivided(by divisor: Int64) -> Int64 {
        let quotient = self / divisor
        return (self % divisor != 0 && (self < 0) != (divisor < 0)) ? quotient - 1 : quotient
    }
}

/// Reads `YYYY-MM-DDTHH:MM:SS[.fraction](Z|±HH:MM)` without allocating per character.
private struct RFC3339Parser {
    struct Parsed {
        var year = 0, month = 0, day = 0, hour = 0, minute = 0, second = 0
        var nanoseconds: Int32 = 0
        var offsetSeconds = 0
    }

    private let bytes: [UInt8]
    private var index = 0

    init(_ text: String) {
        // Longer input is not a timestamp; the cap keeps the parse cheap.
        bytes = text.utf8.count <= 64 ? Array(text.utf8) : []
    }

    mutating func parse() -> Parsed? {
        var result = Parsed()
        guard let year = number(4), expect("-"), let month = number(2), expect("-"), let day = number(2),
              expect("T") || expect("t"), let hour = number(2), expect(":"), let minute = number(2),
              expect(":"), let second = number(2) else { return nil }
        (result.year, result.month, result.day) = (year, month, day)
        (result.hour, result.minute, result.second) = (hour, minute, second)
        if expect(".") {
            var digits = 0
            var nanos = 0
            while index < bytes.count, let digit = digit(at: index) {
                guard digits < 9 else { return nil }
                nanos = nanos * 10 + digit
                digits += 1
                index += 1
            }
            guard digits > 0 else { return nil }
            for _ in digits..<9 { nanos *= 10 }
            result.nanoseconds = Int32(nanos)
        }
        if expect("Z") || expect("z") {
            result.offsetSeconds = 0
        } else {
            guard index < bytes.count, bytes[index] == UInt8(ascii: "+") || bytes[index] == UInt8(ascii: "-") else { return nil }
            let sign = bytes[index] == UInt8(ascii: "-") ? -1 : 1
            index += 1
            guard let hours = number(2), expect(":"), let minutes = number(2), hours < 24, minutes < 60 else { return nil }
            result.offsetSeconds = sign * (hours * 3_600 + minutes * 60)
        }
        return index == bytes.count ? result : nil
    }

    private mutating func expect(_ character: Unicode.Scalar) -> Bool {
        guard index < bytes.count, bytes[index] == UInt8(ascii: character) else { return false }
        index += 1
        return true
    }

    private mutating func number(_ count: Int) -> Int? {
        guard index + count <= bytes.count else { return nil }
        var value = 0
        for offset in 0..<count {
            guard let digit = digit(at: index + offset) else { return nil }
            value = value * 10 + digit
        }
        index += count
        return value
    }

    private func digit(at position: Int) -> Int? {
        let byte = bytes[position]
        return (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte) ? Int(byte - UInt8(ascii: "0")) : nil
    }
}
