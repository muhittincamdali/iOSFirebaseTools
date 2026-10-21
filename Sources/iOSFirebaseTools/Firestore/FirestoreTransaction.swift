import Foundation

/// Reads and writes inside ``FirestoreClient/runTransaction(maxAttempts:_:)``: the reads see
/// one consistent state of the database, and the writes are committed only if none of the
/// documents read changed in the meantime.
///
/// Read every document first, then write; a read after a write throws, as in the Firebase SDKs.
public struct FirestoreTransaction: Sendable {
    private let client: FirestoreClient
    /// The transaction ID from `beginTransaction`, base64 as the REST API sends it.
    let id: String
    private(set) var batch = WriteBatch()

    init(client: FirestoreClient, id: String) {
        self.client = client
        self.id = id
    }

    // MARK: - Reading

    /// The document at `path` as of the transaction, or `nil` if it does not exist.
    public func document<Model: Decodable & Sendable>(_ path: String, as type: Model.Type) async throws -> FirestoreDocument<Model>? {
        try checkNoWrites()
        let name = "\(client.project.documentsRoot)/\(try DocumentPath(path))"
        // batchGet carries the transaction in the body, as the Firebase SDKs send it; the
        // emulator cannot read a transaction ID from a GET's query string.
        let body = try JSONBody.encode(BatchGetBody(documents: [name], transaction: id))
        let response = try await client.send(method: "POST", url: try client.url(for: [], suffix: ":batchGet"), body: body, idempotent: true)
        let results = try JSONBody.decode([BatchGetResult].self, from: response)
        guard let result = results.first(where: { $0.found != nil || $0.missing != nil }) else {
            throw MalformedResponseError(statusCode: response.statusCode, reason: "batchGet returned neither found nor missing")
        }
        return try result.found?.decoded(as: type, root: client.project.documentsRoot)
    }

    /// The documents that match `query` as of the transaction.
    public func documents<Model: Decodable & Sendable>(matching query: FirestoreQuery, as type: Model.Type) async throws -> [FirestoreDocument<Model>] {
        try checkNoWrites()
        let (parent, collectionID) = try query.target()
        let body = try JSONBody.encode(QueryBody(structuredQuery: try query.structuredQuery(collectionID: collectionID), transaction: id))
        let url = try client.url(for: parent?.segments ?? [], suffix: ":runQuery")
        let response = try await client.send(method: "POST", url: url, body: body, idempotent: true)
        let results = try JSONBody.decode([QueryResult].self, from: response)
        return try results.compactMap(\.document).map { try $0.decoded(as: type, root: client.project.documentsRoot) }
    }

    private func checkNoWrites() throws {
        guard batch.count == 0 else {
            throw ValidationError("transaction", "read every document before the first write")
        }
    }

    // MARK: - Writing

    /// Creates the document; the commit fails with ``FirestoreError/Code/alreadyExists`` if it exists.
    public mutating func create(_ value: some Encodable, at path: String, transforms: [FieldPath: FieldTransform] = [:]) throws {
        try batch.create(value, at: path, transforms: transforms)
    }

    /// Writes the document; see ``WriteBatch/set(_:at:merge:transforms:)``.
    public mutating func set(_ value: some Encodable, at path: String, merge: Bool = false, transforms: [FieldPath: FieldTransform] = [:]) throws {
        try batch.set(value, at: path, merge: merge, transforms: transforms)
    }

    /// Changes fields of an existing document; see ``WriteBatch/update(_:fields:transforms:)``.
    public mutating func update(_ path: String, fields: [FieldPath: FirestoreValue], transforms: [FieldPath: FieldTransform] = [:]) throws {
        try batch.update(path, fields: fields, transforms: transforms)
    }

    /// Deletes the document.
    public mutating func delete(_ path: String) throws {
        try batch.delete(path)
    }
}

extension FirestoreClient {
    /// The most attempts ``runTransaction(maxAttempts:_:)`` accepts.
    public static let maxTransactionAttempts = 10

    /// Runs `body` in a read-write transaction and commits its writes atomically.
    ///
    /// ```swift
    /// let views = try await firestore.runTransaction { transaction in
    ///     let note = try await transaction.document(path, as: Note.self)
    ///     let views = (note?.data.views ?? 0) + 1
    ///     try transaction.update(path, fields: ["views": .integer(Int64(views))])
    ///     return views
    /// }
    /// ```
    ///
    /// When another write touched a document the transaction read, Firestore aborts the
    /// commit and `body` runs again from the start, up to `maxAttempts` times in all, so it
    /// should have no side effects outside the transaction. An error thrown by `body` rolls
    /// the transaction back and is rethrown.
    ///
    /// - Parameters:
    ///   - maxAttempts: 1 to ``maxTransactionAttempts``; Firebase's SDKs use 5.
    ///   - body: Reads through the transaction, then writes; its result is returned after the
    ///     commit.
    public func runTransaction<Result: Sendable>(
        maxAttempts: Int = 5,
        _ body: @Sendable (inout FirestoreTransaction) async throws -> Result
    ) async throws -> Result {
        guard (1...Self.maxTransactionAttempts).contains(maxAttempts) else {
            throw ValidationError("maxAttempts", "must be from 1 to \(Self.maxTransactionAttempts)")
        }
        var previousID: String?
        var attempt = 1
        while true {
            let id = try await beginTransaction(retrying: previousID)
            previousID = id
            var transaction = FirestoreTransaction(client: self, id: id)
            let isRetryable = { (error: any Error) in
                (error as? FirestoreError)?.code == .aborted && attempt < maxAttempts
            }
            let result: Result
            do {
                result = try await body(&transaction)
            } catch {
                // A read can be aborted by contention; the transaction still holds its locks.
                await rollback(id)
                guard isRetryable(error) else { throw error }
                try await retryDelay(min(attempt, 2))
                attempt += 1
                continue
            }
            do {
                try await commit(transaction)
                return result
            } catch {
                // A commit that failed has ended the transaction: there is nothing to roll back.
                guard isRetryable(error) else { throw error }
                try await retryDelay(min(attempt, 2))
                attempt += 1
            }
        }
    }

    private func beginTransaction(retrying previousID: String?) async throws -> String {
        let body = try JSONBody.encode(BeginBody(options: .init(readWrite: .init(retryTransaction: previousID))))
        let response = try await send(method: "POST", url: try url(for: [], suffix: ":beginTransaction"), body: body, idempotent: true)
        let transaction = try JSONBody.decode(BeginResponse.self, from: response).transaction
        guard !transaction.isEmpty, transaction.utf8.count <= 1_024 else {
            throw MalformedResponseError(statusCode: response.statusCode, reason: "the transaction ID is empty or too long")
        }
        return transaction
    }

    private func commit(_ transaction: FirestoreTransaction) async throws {
        let writes = try transaction.batch.bodies(root: project.documentsRoot)
        let body = try JSONBody.encode(TransactionCommitBody(writes: writes, transaction: transaction.id))
        // Not retried here: an aborted commit runs the whole transaction again instead.
        _ = try await send(method: "POST", url: try url(for: [], suffix: ":commit"), body: body, idempotent: false)
    }

    /// Releases the transaction's locks. A failure only means the server releases them later.
    private func rollback(_ id: String) async {
        guard let body = try? JSONBody.encode(RollbackBody(transaction: id)),
              let url = try? url(for: [], suffix: ":rollback") else { return }
        _ = try? await send(method: "POST", url: url, body: body, idempotent: false)
    }
}

private struct BeginBody: Encodable {
    struct Options: Encodable {
        struct ReadWrite: Encodable {
            let retryTransaction: String?
        }

        let readWrite: ReadWrite
    }

    let options: Options
}

private struct BeginResponse: Decodable {
    let transaction: String
}

private struct TransactionCommitBody: Encodable {
    let writes: [WriteBody]
    let transaction: String
}

private struct RollbackBody: Encodable {
    let transaction: String
}

private struct BatchGetBody: Encodable {
    let documents: [String]
    let transaction: String
}

private struct BatchGetResult: Decodable {
    let found: RawDocument?
    let missing: String?
}

private struct QueryBody: Encodable {
    let structuredQuery: StructuredQuery
    let transaction: String
}

private struct QueryResult: Decodable {
    let document: RawDocument?
}
