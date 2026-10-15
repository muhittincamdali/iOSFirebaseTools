import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Firestore values in REST JSON")
struct FirestoreValueTests {
    func decode(_ json: String) throws -> FirestoreValue {
        try JSONDecoder().decode(FirestoreValue.self, from: Data(json.utf8))
    }

    func encode(_ value: FirestoreValue) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return String(decoding: try encoder.encode(value), as: UTF8.self)
    }

    @Test("Every type encodes as the REST API expects")
    func encodesEveryType() throws {
        let timestamp = try FirestoreTimestamp(seconds: 1_800_000_000, nanoseconds: 120_000_000)
        #expect(try encode(.null) == #"{"nullValue":null}"#)
        #expect(try encode(true) == #"{"booleanValue":true}"#)
        #expect(try encode(.integer(.max)) == #"{"integerValue":"9223372036854775807"}"#)
        #expect(try encode(1.5) == #"{"doubleValue":1.5}"#)
        #expect(try encode(.double(.nan)) == #"{"doubleValue":"NaN"}"#)
        #expect(try encode(.double(-.infinity)) == #"{"doubleValue":"-Infinity"}"#)
        #expect(try encode(.timestamp(timestamp)) == #"{"timestampValue":"2027-01-15T08:00:00.12Z"}"#)
        #expect(try encode(.bytes(Data([0xFB, 0xFF]))) == #"{"bytesValue":"+/8="}"#)
        #expect(try encode(.geoPoint(GeoPoint(latitude: 41.0, longitude: 29.0))) == #"{"geoPointValue":{"latitude":41,"longitude":29}}"#)
        #expect(try encode(["a", 1]) == #"{"arrayValue":{"values":[{"stringValue":"a"},{"integerValue":"1"}]}}"#)
        #expect(try encode(["k": nil]) == #"{"mapValue":{"fields":{"k":{"nullValue":null}}}}"#)
    }

    @Test("Values round-trip through JSON")
    func roundTrips() throws {
        let values: [FirestoreValue] = [
            .null, false, .integer(.min), .double(-0.0), .double(.infinity), "çağrı 🔥", .bytes(Data()), .reference("projects/p/databases/(default)/documents/a/b"),
            .timestamp(try FirestoreTimestamp(seconds: -62_135_596_800, nanoseconds: 0)), [], [:], ["nested": ["list": [1, 2.5, ["deep": true]]]],
        ]
        for value in values {
            #expect(try decode(try encode(value)) == value)
        }
        guard case let .double(nan) = try decode(try encode(.double(.nan))) else { Issue.record("not a double"); return }
        #expect(nan.isNaN)
    }

    @Test("proto3 leaves out zero and empty fields")
    func readsOmittedDefaults() throws {
        #expect(try decode(#"{"geoPointValue":{}}"#) == .geoPoint(try GeoPoint(latitude: 0, longitude: 0)))
        #expect(try decode(#"{"arrayValue":{}}"#) == [])
        #expect(try decode(#"{"mapValue":{}}"#) == [:])
        #expect(try decode(#"{"integerValue":7}"#) == .integer(7))
        #expect(try decode(#"{"bytesValue":"-_8"}"#) == .bytes(Data([0xFB, 0xFF])))
    }

    @Test("Integers outside Int64 and malformed numbers are errors, not traps", arguments: [
        #"{"integerValue":"9223372036854775808"}"#, #"{"integerValue":"-9223372036854775809"}"#,
        #"{"integerValue":"1e3"}"#, #"{"integerValue":"12abc"}"#, #"{"integerValue":"999999999999999999999999999999"}"#,
        #"{"integerValue":1e300}"#, #"{"integerValue":1.5}"#, #"{"doubleValue":"nan"}"#, #"{"doubleValue":"1.5"}"#,
        #"{"doubleValue":true}"#,
    ])
    func rejectsBadNumbers(_ json: String) {
        #expect(throws: DecodingError.self) { try decode(json) }
    }

    @Test("Objects without exactly one known type are rejected", arguments: [
        "{}", #"{"stringValue":"a","integerValue":"1"}"#, #"{"unknownValue":1}"#, "[]", "null",
        #"{"geoPointValue":{"latitude":91}}"#, #"{"geoPointValue":{"longitude":-180.5}}"#, #"{"bytesValue":"***"}"#,
        #"{"timestampValue":"yesterday"}"#,
    ])
    func rejectsBadShapes(_ json: String) {
        #expect(throws: (any Error).self) { try decode(json) }
    }

    @Test("Firestore's nesting and naming rules are enforced")
    func validatesRules() throws {
        try FirestoreValue.array([["inner": [1]]]).validate()
        #expect(throws: ValidationError.self) { try FirestoreValue.array([[1]]).validate() }
        #expect(throws: ValidationError.self) { try FirestoreValue.map(["__name__": 1]).validate() }
        #expect(throws: ValidationError.self) { try FirestoreValue.map(["": 1]).validate() }
        #expect(throws: ValidationError.self) { try FirestoreValue.map([String(repeating: "k", count: 1_501): 1]).validate() }

        var deep: FirestoreValue = 1
        for _ in 0..<20 { deep = .map(["a": deep]) }
        try deep.validate()
        #expect(throws: ValidationError.self) { try FirestoreValue.map(["a": deep]).validate() }
    }

    @Test("Geo points outside the globe or NaN are rejected", arguments: [
        (91.0, 0.0), (-91.0, 0.0), (0.0, 181.0), (Double.nan, 0.0), (0.0, Double.infinity),
    ])
    func rejectsGeoPoints(_ latitude: Double, _ longitude: Double) {
        #expect(throws: ValidationError.self) { try GeoPoint(latitude: latitude, longitude: longitude) }
    }
}

@Suite("Timestamps")
struct TimestampTests {
    @Test("RFC 3339 text parses to the right instant", arguments: [
        ("2026-10-15T08:41:00Z", 1_792_053_660, 0),
        ("2026-10-15T11:41:00+03:00", 1_792_053_660, 0),
        ("2026-10-15t08:41:00.5z", 1_792_053_660, 500_000_000),
        ("2026-10-15T08:41:00.123456789Z", 1_792_053_660, 123_456_789),
        ("1969-12-31T23:59:59.999Z", -1, 999_000_000),
        ("2024-02-29T00:00:00Z", 1_709_164_800, 0),
        ("0001-01-01T00:00:00Z", -62_135_596_800, 0),
        ("9999-12-31T23:59:59.999999999Z", 253_402_300_799, 999_999_999),
    ] as [(String, Int64, Int32)])
    func parses(_ text: String, _ seconds: Int64, _ nanos: Int32) throws {
        let timestamp = try FirestoreTimestamp(rfc3339: text)
        #expect(timestamp.seconds == seconds)
        #expect(timestamp.nanoseconds == nanos)
        #expect(try FirestoreTimestamp(rfc3339: timestamp.rfc3339) == timestamp)
    }

    @Test("Impossible dates and other formats are rejected", arguments: [
        "2026-02-30T00:00:00Z", "2025-02-29T00:00:00Z", "2026-13-01T00:00:00Z", "2026-10-15T24:00:00Z",
        "2026-10-15T08:60:00Z", "2026-10-15T08:41:60Z", "2026-10-15T08:41:00", "2026-10-15 08:41:00Z",
        "2026-10-15T08:41:00.Z", "2026-10-15T08:41:00.1234567891Z", "2026-10-15T08:41:00+24:00",
        "0001-01-01T00:00:00+01:00", "9999-12-31T23:59:59-01:00", "+2026-10-15T08:41:00Z", "２０２６-10-15T08:41:00Z",
        String(repeating: "9", count: 100),
    ])
    func rejects(_ text: String) {
        #expect(throws: ValidationError.self) { try FirestoreTimestamp(rfc3339: text) }
    }

    @Test("Dates convert both ways; NaN, infinite and out-of-range dates throw", arguments: [
        Double.nan, .infinity, -.infinity, 1e300, -62_135_596_801, 253_402_300_800,
    ])
    func rejectsDates(_ interval: Double) {
        #expect(throws: ValidationError.self) { try FirestoreTimestamp(Date(timeIntervalSince1970: interval)) }
    }

    @Test("Dates keep microseconds and order correctly")
    func convertsDates() throws {
        let date = Date(timeIntervalSince1970: -1.25)
        let timestamp = try FirestoreTimestamp(date)
        #expect(timestamp.seconds == -2)
        #expect(timestamp.nanoseconds == 750_000_000)
        #expect(timestamp.date == date)
        #expect(timestamp.rfc3339 == "1969-12-31T23:59:58.75Z")
        #expect(try FirestoreTimestamp(seconds: 1, nanoseconds: 0) > timestamp)
        #expect(throws: ValidationError.self) { try FirestoreTimestamp(seconds: 0, nanoseconds: 1_000_000_000) }
        #expect(throws: (any Error).self) { try JSONDecoder().decode(FirestoreTimestamp.self, from: Data(#"{"seconds":0,"nanoseconds":-1}"#.utf8)) }
    }
}
