import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Firestore transactions")
struct FirestoreTransactionTests {
    struct Counter: Codable, Equatable, Sendable {
        var count: Int
    }

    static let root = "projects/demo-fixture/databases/(default)/documents"

    static func counterJSON(_ count: Int) -> String {
        #"{"name":"\#(root)/counters/c","fields":{"count":{"integerValue":"\#(count)"}}}"#
    }

    /// Answers like Firestore: a transaction ID per begin, the counter for reads, and the
    /// commit statuses in order (409 ABORTED or 200).
    func transport(commits: [Int] = [200], transactionIDs: [String] = ["dHgx+/a=", "dHgy"]) -> MockTransport {
        let state = CommitState(statuses: commits)
        let ids = BeginState(ids: transactionIDs)
        return MockTransport { request, _ in
            let url = request.url.absoluteString
            if url.hasSuffix(":beginTransaction") { return .json(#"{"transaction":"\#(ids.next())"}"#) }
            if url.hasSuffix(":rollback") { return .json("{}") }
            if url.hasSuffix(":commit") {
                let status = state.next()
                return status == 200 ? .json(#"{"commitTime":"2026-10-21T08:00:00Z"}"#)
                    : .googleError(status, message: "Transaction lock timeout.", code: "ABORTED")
            }
            if url.hasSuffix(":batchGet") { return .json(#"[{"found":\#(Self.counterJSON(41)),"readTime":"2026-10-21T08:00:00Z"}]"#) }
            return .json(#"[{"readTime":"2026-10-21T08:00:00Z"}]"#)
        }
    }

    func client(_ transport: MockTransport) throws -> FirestoreClient {
        FirestoreClient(project: try Fixtures.project(), transport: transport, retryDelay: { _ in })
    }

    @Test("Reads carry the transaction ID, and the commit carries it with the writes")
    func commitsWrites() async throws {
        let transport = transport()
        let result = try await client(transport).runTransaction { transaction in
            let counter = try #require(try await transaction.document("counters/c", as: Counter.self))
            try transaction.update("counters/c", fields: ["count": .integer(Int64(counter.data.count + 1))])
            return counter.data.count + 1
        }
        #expect(result == 42)
        let requests = transport.requests
        #expect(requests.map { $0.url.path.split(separator: "/").last.map(String.init) }
            == ["documents:beginTransaction", "documents:batchGet", "documents:commit"])
        #expect(requests[0].jsonBody["options"] as? [String: [String: String]] == ["readWrite": [:]])
        #expect(requests[1].jsonBody["documents"] as? [String] == ["\(Self.root)/counters/c"])
        #expect(requests[1].jsonBody["transaction"] as? String == "dHgx+/a=")
        #expect(requests[2].jsonBody["transaction"] as? String == "dHgx+/a=")
        let writes = try #require(requests[2].jsonBody["writes"] as? [[String: Any]])
        #expect(writes.count == 1)
        #expect((writes[0]["update"] as? [String: Any])?["name"] as? String == "\(Self.root)/counters/c")
    }

    @Test("A missing document reads as nil; an empty answer is malformed")
    func readsMissing() async throws {
        let missing = MockTransport { request, _ in
            request.url.absoluteString.hasSuffix(":batchGet")
                ? .json(#"[{"missing":"\#(Self.root)/counters/c","readTime":"2026-10-21T08:00:00Z"}]"#)
                : .json(#"{"transaction":"dHgx"}"#)
        }
        let document = try await client(missing).runTransaction { try await $0.document("counters/c", as: Counter.self) }
        #expect(document == nil)
        let empty = MockTransport { request, _ in
            .json(request.url.absoluteString.hasSuffix(":batchGet") ? "[]" : #"{"transaction":"dHgx"}"#)
        }
        await #expect(throws: MalformedResponseError.self) {
            try await client(empty).runTransaction { try await $0.document("counters/c", as: Counter.self) }
        }
    }

    @Test("An aborted commit runs the body again in a retry of the same transaction")
    func retriesAbortedCommit() async throws {
        let transport = transport(commits: [409, 200])
        let runs = RunCounter()
        _ = try await client(transport).runTransaction { transaction in
            runs.increment()
            _ = try await transaction.document("counters/c", as: Counter.self)
            try transaction.delete("counters/c")
        }
        #expect(runs.value == 2)
        let begins = transport.requests.filter { $0.url.absoluteString.hasSuffix(":beginTransaction") }
        #expect(begins.count == 2)
        #expect((begins[1].jsonBody["options"] as? [String: [String: String]])?["readWrite"]?["retryTransaction"] == "dHgx+/a=")
        #expect(!transport.requests.contains { $0.url.absoluteString.hasSuffix(":rollback") })
    }

    @Test("A failed read is not sent again with its transaction ID; the transaction starts again", arguments: [
        (409, "ABORTED"), (503, "UNAVAILABLE"),
    ])
    func retriesFailedRead(_ status: Int, _ code: String) async throws {
        let reads = RunCounter()
        let ids = BeginState(ids: ["dHgx", "dHgy"])
        let transport = MockTransport { request, _ in
            let url = request.url.absoluteString
            if url.hasSuffix(":beginTransaction") { return .json(#"{"transaction":"\#(ids.next())"}"#) }
            if url.hasSuffix(":rollback") { return .json("{}") }
            if url.hasSuffix(":commit") { return .json(#"{"commitTime":"2026-10-21T08:00:00Z"}"#) }
            reads.increment()
            return reads.value == 1 ? .googleError(status, message: "Transaction lock timeout.", code: code)
                : .json(#"[{"found":\#(Self.counterJSON(41)),"readTime":"2026-10-21T08:00:00Z"}]"#)
        }
        let count = try await client(transport).runTransaction { transaction in
            try await transaction.document("counters/c", as: Counter.self)?.data.count
        }
        #expect(count == 41)
        let readIDs = transport.requests.filter { $0.url.absoluteString.hasSuffix(":batchGet") }.map { $0.jsonBody["transaction"] as? String }
        #expect(readIDs == ["dHgx", "dHgy"])
        let rollbacks = transport.requests.filter { $0.url.absoluteString.hasSuffix(":rollback") }
        #expect(rollbacks.map { $0.jsonBody["transaction"] as? String } == ["dHgx"])
    }

    @Test("After maxAttempts aborted commits the abort is thrown")
    func givesUp() async throws {
        let transport = transport(commits: [409, 409, 409])
        let error = await #expect(throws: FirestoreError.self) {
            try await client(transport).runTransaction(maxAttempts: 3) { transaction in try transaction.delete("counters/c") }
        }
        #expect(error?.code == .aborted)
        #expect(transport.requests.filter { $0.url.absoluteString.hasSuffix(":commit") }.count == 3)
    }

    @Test("An error in the body rolls back and is rethrown without a commit")
    func rollsBack() async throws {
        struct Cancelled: Error {}
        let transport = transport()
        await #expect(throws: Cancelled.self) {
            try await client(transport).runTransaction { _ -> Int in throw Cancelled() }
        }
        let last = try #require(transport.requests.last)
        #expect(last.url.absoluteString.hasSuffix(":rollback"))
        #expect(last.jsonBody["transaction"] as? String == "dHgx+/a=")
        #expect(!transport.requests.contains { $0.url.absoluteString.hasSuffix(":commit") })
    }

    @Test("Reads after a write and out-of-range attempts are rejected")
    func rejectsMisuse() async throws {
        let transport = transport()
        await #expect(throws: ValidationError.self) {
            try await client(transport).runTransaction { transaction in
                try transaction.delete("counters/c")
                return try await transaction.document("counters/c", as: Counter.self)
            }
        }
        #expect(transport.requests.last?.url.absoluteString.hasSuffix(":rollback") == true)
        let unused = self.transport()
        for attempts in [0, FirestoreClient.maxTransactionAttempts + 1] {
            await #expect(throws: ValidationError.self) {
                try await client(unused).runTransaction(maxAttempts: attempts) { _ in }
            }
        }
        #expect(unused.requests.isEmpty)
    }
}

/// Counts how often a transaction body ran.
final class RunCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int { lock.withLock { count } }
    func increment() { lock.withLock { count += 1 } }
}

private final class CommitState: @unchecked Sendable {
    private let lock = NSLock()
    private var statuses: [Int]
    init(statuses: [Int]) { self.statuses = statuses }
    func next() -> Int { lock.withLock { statuses.isEmpty ? 200 : statuses.removeFirst() } }
}

private final class BeginState: @unchecked Sendable {
    private let lock = NSLock()
    private var ids: [String]
    init(ids: [String]) { self.ids = ids }
    func next() -> String { lock.withLock { ids.count > 1 ? ids.removeFirst() : ids[0] } }
}
