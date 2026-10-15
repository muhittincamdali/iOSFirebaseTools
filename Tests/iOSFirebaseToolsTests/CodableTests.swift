import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Encoding and decoding models")
struct CodableTests {
    struct Note: Codable, Equatable, Sendable {
        enum Priority: String, Codable { case low, high }
        struct Location: Codable, Equatable { var name: String; var point: GeoPoint }

        var text: String
        var pinned: Bool
        var views: Int
        var rating: Double
        var createdAt: Date
        var attachment: Data
        var link: URL
        var priority: Priority
        var tags: [String]
        var location: Location?
        var editedAt: Date?
        var counts: [String: UInt8]
    }

    static let sample = Note(
        text: "Buy milk", pinned: true, views: 3, rating: 4.5, createdAt: Date(timeIntervalSince1970: 1_800_000_000.25),
        attachment: Data([1, 2, 3]), link: URL(string: "https://example.com/a?b=c")!, priority: .high,
        tags: ["home", "today"], location: Note.Location(name: "Kadıköy", point: try! GeoPoint(latitude: 40.99, longitude: 29.03)),
        editedAt: nil, counts: ["a": 1, "b": 255]
    )

    @Test("A model maps to Firestore types and back")
    func roundTrip() throws {
        let fields = try FirestoreEncoder().encode(Self.sample)
        #expect(fields["text"] == "Buy milk")
        #expect(fields["views"] == .integer(3))
        #expect(fields["createdAt"] == .timestamp(try FirestoreTimestamp(seconds: 1_800_000_000, nanoseconds: 250_000_000)))
        #expect(fields["attachment"] == .bytes(Data([1, 2, 3])))
        #expect(fields["link"] == "https://example.com/a?b=c")
        #expect(fields["priority"] == "high")
        #expect(fields["location"] == ["name": "Kadıköy", "point": .geoPoint(try GeoPoint(latitude: 40.99, longitude: 29.03))])
        #expect(fields["editedAt"] == nil, "nil optionals are left out")
        #expect(try FirestoreDecoder().decode(Note.self, from: fields) == Self.sample)
    }

    @Test("Integers convert only when they fit")
    func checksIntegerRanges() throws {
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encodeValue(UInt64.max) }
        #expect(try FirestoreEncoder().encodeValue(UInt64(Int64.max)) == .integer(.max))
        let decoder = FirestoreDecoder()
        #expect(throws: DecodingError.self) { try decoder.decode(Int8.self, from: .integer(300)) }
        #expect(throws: DecodingError.self) { try decoder.decode(UInt.self, from: .integer(-1)) }
        #expect(throws: DecodingError.self) { try decoder.decode(Int.self, from: .double(2.5)) }
        #expect(throws: DecodingError.self) { try decoder.decode(Int.self, from: .double(.nan)) }
        #expect(throws: DecodingError.self) { try decoder.decode(Int.self, from: .double(.infinity)) }
        #expect(throws: DecodingError.self) { try decoder.decode(Int64.self, from: .double(1e19)) }
        #expect(throws: DecodingError.self) { try decoder.decode(Float.self, from: .double(1e300)) }
        #expect(try decoder.decode(Int.self, from: .double(3)) == 3)
        #expect(try decoder.decode(Double.self, from: .integer(7)) == 7)
        #expect(try decoder.decode(Float.self, from: .double(.infinity)) == .infinity)
    }

    @Test("Dates outside Firestore's range are encoding errors")
    func checksDates() throws {
        for interval in [Double.nan, .infinity, -1e15, 1e15] {
            #expect(throws: EncodingError.self) { try FirestoreEncoder().encodeValue(Date(timeIntervalSince1970: interval)) }
        }
        #expect(try FirestoreEncoder().encodeValue(Date.distantFuture) != .null)
    }

    @Test("Type mismatches and missing fields are decoding errors")
    func reportsMismatches() throws {
        var fields = try FirestoreEncoder().encode(Self.sample)
        fields["views"] = "three"
        #expect(throws: DecodingError.self) { try FirestoreDecoder().decode(Note.self, from: fields) }
        fields["views"] = nil
        #expect(throws: DecodingError.self) { try FirestoreDecoder().decode(Note.self, from: fields) }
        #expect(throws: DecodingError.self) { try FirestoreDecoder().decode(Date.self, from: "2026-10-15T08:41:00Z") }
        #expect(throws: DecodingError.self) { try FirestoreDecoder().decode([String].self, from: ["a": 1]) }
    }

    @Test("Values Firestore cannot store are rejected when encoding")
    func rejectsUnstorableValues() throws {
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encodeValue([[1, 2], [3]]) }
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode(["__reserved__": 1]) }
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode(["": 1]) }
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode([1, 2]) }
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode("text") }
    }

    final class Node: Encodable {
        var next: Node?
    }

    @Test("A reference cycle is an error instead of a stack overflow")
    func stopsCycles() {
        let node = Node()
        node.next = node
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode(node) }
        node.next = nil
    }

    @Test("Deep nesting beyond Firestore's 20 levels is rejected")
    func limitsDepth() throws {
        var value: [String: FirestoreValue] = ["leaf": 1]
        for _ in 0..<19 { value = ["n": .map(value)] }
        _ = try FirestoreEncoder().encode(value)
        #expect(throws: EncodingError.self) { try FirestoreEncoder().encode(["n": FirestoreValue.map(value)]) }
    }

    struct Child: Codable, Equatable {
        var values: [Int?]
        var nested: [[String: Int]]
    }

    @Test("Optionals inside arrays and maps inside arrays survive")
    func collections() throws {
        let child = Child(values: [1, nil, 3], nested: [["a": 1], [:]])
        let fields = try FirestoreEncoder().encode(child)
        #expect(fields["values"] == [1, nil, 3])
        #expect(try FirestoreDecoder().decode(Child.self, from: fields) == child)
    }
}

@Suite("Document, collection and field paths")
struct PathTests {
    @Test("Valid paths parse", arguments: ["notes/a", "users/ada/notes/n1", "a b/ç ğ", "notes/x:commit", "notes/%2F", "notes/a?b#c"])
    func parsesDocumentPaths(_ text: String) throws {
        let path = try DocumentPath(text)
        #expect(path.description == text)
        #expect(path.collection.description == String(text[..<text.lastIndex(of: "/")!]))
    }

    @Test("Invalid paths are rejected", arguments: [
        "", "notes", "notes/", "/notes/a", "notes//a", "notes/.", "notes/..", "notes/__id1__", "users/ada/notes",
        "notes/" + String(repeating: "x", count: 1_501), String(repeating: "c/d/", count: 2_000) + "c/d",
    ])
    func rejectsDocumentPaths(_ text: String) {
        #expect(throws: ValidationError.self) { try DocumentPath(text) }
    }

    @Test("Collection paths and children")
    func collectionPaths() throws {
        let notes = try CollectionPath("users/ada/notes")
        #expect(notes.collectionID == "notes")
        #expect(notes.parent?.description == "users/ada")
        #expect(try notes.document("n1").description == "users/ada/notes/n1")
        #expect(throws: ValidationError.self) { try notes.document("a/b") }
        #expect(try CollectionPath("notes").parent == nil)
        #expect(throws: ValidationError.self) { try CollectionPath("notes/a") }
    }

    @Test("Field names that are not identifiers are quoted", arguments: [
        (["createdAt"], "createdAt"), (["address", "city"], "address.city"), (["first name"], "`first name`"),
        (["1st"], "`1st`"), (["a.b"], "`a.b`"), (["back`tick"], #"`back\`tick`"#), (["slash\\"], #"`slash\\`"#),
        (["çay"], "`çay`"), (["_private"], "_private"),
    ])
    func quotesFieldNames(_ names: [String], _ encoded: String) throws {
        #expect(try FieldPath(names).encoded == encoded)
    }

    @Test("Invalid field paths are rejected")
    func rejectsFieldPaths() {
        #expect(throws: ValidationError.self) { try FieldPath([]) }
        #expect(throws: ValidationError.self) { try FieldPath(dotted: "a..b") }
        #expect(throws: ValidationError.self) { try FieldPath(dotted: "__name__") }
        #expect(throws: ValidationError.self) { try FieldPath([String(repeating: "f", count: 1_501)]) }
        #expect(FieldPath.documentID.encoded == "__name__")
    }

    @Test("URL segments keep IDs with reserved characters in one segment", arguments: [
        ("a?b#c", "a%3Fb%23c"), ("x:commit", "x%3Acommit"), ("%2F", "%252F"), ("a b", "a%20b"), ("ç", "%C3%A7"), ("a;b", "a%3Bb"),
    ])
    func encodesURLSegments(_ segment: String, _ encoded: String) {
        #expect(PathRules.urlSegment(segment) == encoded)
    }
}
