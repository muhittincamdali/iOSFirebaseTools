import Foundation
import Testing
@testable import iOSFirebaseTools

struct TestNote: Codable, Equatable, Sendable {
    var text: String
    var ownerID: String
}

@Suite("Queries")
struct QueryTests {
    func body(_ query: FirestoreQuery) throws -> [String: Any] {
        let (_, collectionID) = try query.target()
        let data = try JSONBody.encode(query.structuredQuery(collectionID: collectionID))
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    @Test("Filters, order and limit build a StructuredQuery")
    func buildsStructuredQuery() throws {
        let query = FirestoreQuery(collection: "notes").filter("ownerID", .equal, "u1").filter("views", .greaterThan, 10)
            .order(by: "views", descending: true).limit(5)
        let json = try body(query)
        #expect((json["from"] as? [[String: Any]])?.first?["collectionId"] as? String == "notes")
        let composite = (json["where"] as? [String: Any])?["compositeFilter"] as? [String: Any]
        #expect(composite?["op"] as? String == "AND")
        #expect((composite?["filters"] as? [Any])?.count == 2)
        #expect(((json["orderBy"] as? [[String: Any]])?.first?["direction"]) as? String == "DESCENDING")
        #expect(json["limit"] as? Int == 5)
    }

    @Test("Comparing with nil or NaN becomes a unary filter", arguments: [
        (FirestoreQuery.Operator.equal, true, "IS_NULL"), (.notEqual, true, "IS_NOT_NULL"), (.equal, false, "IS_NAN"), (.notEqual, false, "IS_NOT_NAN"),
    ])
    func unaryFilters(_ op: FirestoreQuery.Operator, _ null: Bool, _ expected: String) throws {
        let value: FirestoreValue = null ? .null : .double(.nan)
        let json = try body(FirestoreQuery(collection: "notes").filter("deletedAt", op, value))
        let unary = (json["where"] as? [String: Any])?["unaryFilter"] as? [String: Any]
        #expect(unary?["op"] as? String == expected)
    }

    @Test("Invalid queries fail when they run, not when they are built")
    func reportsProblems() throws {
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").filter("x", .lessThan, FirestoreValue.null)) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").filter("x", .in, "not-an-array")) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").filter("x", .in, Array(0..<31))) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").filter("x", .notIn, Array(0..<11))) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").filter("x", .equal, UInt64.max)) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").limit(0)) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes").limit(.max)) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery(collection: "notes/a")) }
        #expect(throws: ValidationError.self) { try body(FirestoreQuery.collectionGroup("users/ada/notes")) }
        #expect(try body(FirestoreQuery(collection: "notes").filter("tags", .in, ["a", "b"]))["where"] != nil)
    }

    @Test("Subcollection and collection group targets")
    func targets() throws {
        let (parent, id) = try FirestoreQuery(collection: "users/ada/notes").target()
        #expect(parent?.description == "users/ada")
        #expect(id == "notes")
        let group = try body(FirestoreQuery.collectionGroup("notes"))
        #expect((group["from"] as? [[String: Any]])?.first?["allDescendants"] as? Bool == true)
    }
}

@Suite("Write batches")
struct WriteBatchTests {
    @Test("Field paths nest into maps and must not overlap")
    func nestsFields() throws {
        let nested = try WriteBatch.nest(["address.city": "Izmir", "address.zip": "35000", "name": "Ada"])
        #expect(nested == ["address": ["city": "Izmir", "zip": "35000"], "name": "Ada"])
        #expect(throws: ValidationError.self) { try WriteBatch.checkDisjoint(["address", "address.city"]) }
        #expect(throws: ValidationError.self) { try WriteBatch.checkDisjoint(["a", "a"]) }
        try WriteBatch.checkDisjoint(["a.b", "a.c", "ab"])
    }

    @Test("A merge masks every leaf field")
    func mergeMask() throws {
        let paths = try WriteBatch.leafPaths(of: ["a": ["b": 1, "c": [:]], "d": [1]], under: [])
        #expect(paths.map(\.encoded) == ["a.b", "a.c", "d"])
    }

    @Test("Writes become REST Write objects with the right preconditions")
    func writeBodies() throws {
        var batch = WriteBatch()
        try batch.create(TestNote(text: "a", ownerID: "u1"), at: "notes/n1", transforms: ["createdAt": .serverTimestamp])
        try batch.set(TestNote(text: "b", ownerID: "u1"), at: "notes/n2", merge: true)
        try batch.update("counters/notes", fields: [:], transforms: ["total": .increment(1)])
        try batch.delete("notes/n3")
        let root = "projects/p/databases/(default)/documents"
        let json = try JSONSerialization.jsonObject(with: JSONBody.encode(batch.bodies(root: root))) as! [[String: Any]]
        #expect((json[0]["currentDocument"] as? [String: Bool]) == ["exists": false])
        #expect(((json[0]["updateTransforms"] as? [[String: Any]])?.first?["setToServerValue"]) as? String == "REQUEST_TIME")
        #expect((json[1]["updateMask"] as? [String: [String]]) == ["fieldPaths": ["ownerID", "text"]])
        #expect(json[1]["currentDocument"] == nil)
        #expect((json[2]["currentDocument"] as? [String: Bool]) == ["exists": true])
        #expect((json[2]["updateMask"] as? [String: [String]]) == ["fieldPaths": []])
        #expect(json[3]["delete"] as? String == "\(root)/notes/n3")
    }

    @Test("Batches stop at 500 writes and reject bad transforms")
    func limits() throws {
        var batch = WriteBatch()
        for index in 0..<500 { try batch.delete("notes/n\(index)") }
        #expect(throws: ValidationError.self) { try batch.delete("notes/one-more") }
        var other = WriteBatch()
        try other.update("c/d", fields: [:], transforms: ["n": .increment(.double(.nan))])
        #expect(throws: ValidationError.self) { try other.bodies(root: "r") }
        #expect(throws: ValidationError.self) { try other.update("c/d", fields: ["a": 1], transforms: ["a.b": .serverTimestamp]) }
        #expect(throws: ValidationError.self) { try other.update("c/d", fields: ["a": [[1]]]) }
    }
}

@Suite("Firestore client")
struct FirestoreClientTests {
    let documentJSON = #"""
    {"name":"projects/demo-fixture/databases/(default)/documents/notes/a%20b","fields":{"text":{"stringValue":"hi"},"ownerID":{"stringValue":"u1"}},"createTime":"2026-10-15T08:41:00.000001Z","updateTime":"2026-10-15T08:41:00.000001Z"}
    """#

    func client(_ transport: MockTransport, credentials: FirestoreClient.Credentials = .none) throws -> FirestoreClient {
        FirestoreClient(project: try Fixtures.project(), credentials: credentials, transport: transport, retryDelay: { _ in })
    }

    @Test("Reading a document builds an encoded URL and decodes the model")
    func readsDocument() async throws {
        let json = documentJSON.replacingOccurrences(of: "notes/a%20b", with: "notes/a b?#")
        let transport = MockTransport(json: json)
        let document = try #require(try await client(transport).document("notes/a b?#", as: TestNote.self))
        #expect(transport.requests[0].url.absoluteString
            == "https://firestore.googleapis.com/v1/projects/demo-fixture/databases/(default)/documents/notes/a%20b%3F%23")
        #expect(document.id == "a b?#")
        #expect(document.data == TestNote(text: "hi", ownerID: "u1"))
        #expect(document.updateTime?.nanoseconds == 1_000)
    }

    @Test("A missing document is nil; other errors are thrown with their status")
    func mapsErrors() async throws {
        let missing = MockTransport { _, _ in .googleError(404, message: "Document not found", code: "NOT_FOUND") }
        #expect(try await client(missing).document("notes/x", as: TestNote.self) == nil)

        let denied = MockTransport { _, _ in .googleError(403, message: "Missing or insufficient permissions.", code: "PERMISSION_DENIED") }
        let error = await #expect(throws: FirestoreError.self) { try await client(denied).document("notes/x", as: TestNote.self) }
        #expect(error?.code == .permissionDenied)
    }

    @Test("A document from another database is rejected")
    func rejectsForeignDocuments() async throws {
        let json = documentJSON.replacingOccurrences(of: "demo-fixture", with: "other-project")
        await #expect(throws: MalformedResponseError.self) { try await client(MockTransport(json: json)).document("notes/x", as: TestNote.self) }
    }

    @Test("Reads retry twice on transient errors; commits never retry")
    func retries() async throws {
        let flaky = MockTransport { _, number in
            number < 2 ? .googleError(503, message: "unavailable", code: "UNAVAILABLE") : .json(#"{"documents":[]}"#)
        }
        let page = try await client(flaky).documents(in: "notes", as: TestNote.self)
        #expect(page.documents.isEmpty)
        #expect(flaky.requests.count == 3)

        let down = MockTransport { _, _ in .googleError(503, message: "unavailable", code: "UNAVAILABLE") }
        await #expect(throws: FirestoreError.self) { try await client(down).documents(in: "notes", as: TestNote.self) }
        #expect(down.requests.count == 3)

        let commitDown = MockTransport { _, _ in .googleError(503, message: "unavailable", code: "UNAVAILABLE") }
        await #expect(throws: FirestoreError.self) { try await client(commitDown).delete("notes/x") }
        #expect(commitDown.requests.count == 1)
    }

    @Test("A 401 is retried once with a refreshed ID token")
    func refreshesOnUnauthenticated() async throws {
        let authTransport = MockTransport { request, _ in
            request.url.path.hasSuffix("/token") ? Fixtures.refreshResponse() : Fixtures.signInResponse()
        }
        let auth = FirebaseAuthClient(project: try Fixtures.project(), transport: authTransport, store: InMemorySessionStore())
        try await auth.signIn(email: "ada@example.com", password: "pw")
        let firestore = MockTransport { request, number in
            number == 0 ? .googleError(401, message: "expired", code: "UNAUTHENTICATED") : .json(documentJSON)
        }
        _ = try await client(firestore, credentials: .user(auth)).document("notes/x", as: TestNote.self)
        #expect(firestore.requests.map { $0.headers["Authorization"] } == ["Bearer id-token-1", "Bearer id-token-2"])
    }

    @Test("Adding a document commits a create with a 20-character ID")
    func addsDocument() async throws {
        let transport = MockTransport(json: #"{"writeResults":[{}],"commitTime":"2026-10-15T08:41:00Z"}"#)
        let path = try await client(transport, credentials: .emulatorOwner).add(TestNote(text: "a", ownerID: "u1"), to: "notes")
        #expect(path.hasPrefix("notes/") && path.count == 26)
        let request = try #require(transport.requests.first)
        #expect(request.url.absoluteString.hasSuffix("/documents:commit"))
        #expect(request.headers["Authorization"] == "Bearer owner")
        let write = (request.jsonBody["writes"] as? [[String: Any]])?.first
        #expect((write?["update"] as? [String: Any])?["name"] as? String == "projects/demo-fixture/databases/(default)/documents/\(path)")
        #expect(Set((0..<200).map { _ in FirestoreClient.newDocumentID() }).count == 200)
    }

    @Test("Queries run against the parent document and skip empty results")
    func runsQueries() async throws {
        let transport = MockTransport(json: #"[{"readTime":"2026-10-15T08:41:00Z"},{"document":\#(documentJSON),"readTime":"2026-10-15T08:41:00Z"}]"#)
        let query = FirestoreQuery(collection: "users/ada/notes").filter("ownerID", .equal, "u1")
        let results = try await client(transport).documents(matching: query, as: TestNote.self)
        #expect(results.count == 1)
        #expect(transport.requests[0].url.absoluteString.hasSuffix("/documents/users/ada:runQuery"))
    }

    @Test("Page sizes and request sizes are bounded")
    func boundsSizes() async throws {
        let transport = MockTransport(json: "{}")
        await #expect(throws: ValidationError.self) { try await client(transport).documents(in: "notes", as: TestNote.self, pageSize: 0) }
        await #expect(throws: ValidationError.self) { try await client(transport).documents(in: "notes", as: TestNote.self, pageSize: 1_001) }
        let big = String(repeating: "x", count: 1_000_000)
        var batch = WriteBatch()
        for index in 0..<11 { try batch.set(TestNote(text: big, ownerID: "u"), at: "notes/n\(index)") }
        await #expect(throws: ValidationError.self) { try await client(transport).commit(batch) }
        #expect(transport.requests.isEmpty)
    }
}
