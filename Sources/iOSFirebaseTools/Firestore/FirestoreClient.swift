import Foundation

/// Reads and writes Cloud Firestore documents over the REST API, with `Codable` models.
///
/// ```swift
/// let firestore = FirestoreClient(project: project, credentials: .user(auth))
/// let path = try await firestore.add(Note(text: "Buy milk"), to: "notes")
/// let note = try await firestore.document(path, as: Note.self)
/// ```
///
/// Requests carry the signed-in user's ID token, so Security Rules see `request.auth`. Reads
/// are retried up to twice on transient errors, and any request answered `401` is sent once
/// more with a refreshed token. Firestore's real-time listeners need gRPC and are not part of
/// the REST API; poll with a query instead.
public struct FirestoreClient: Sendable {
    /// How requests are authorized.
    public enum Credentials: Sendable {
        /// No `Authorization` header: Security Rules see an unauthenticated request.
        case none
        /// The ID token of the user signed in with a ``FirebaseAuthClient``.
        case user(FirebaseAuthClient)
        /// A bearer token from your own code, such as a Google OAuth 2.0 access token on a server.
        case bearer(@Sendable () async throws -> String)
        /// `Bearer owner`, which the Firestore emulator accepts as an admin that bypasses
        /// Security Rules. Useful to seed or inspect data in tests; production rejects it.
        case emulatorOwner
    }

    public let project: FirebaseProject
    private let credentials: Credentials
    private let transport: any HTTPTransport
    let retryDelay: @Sendable (Int) async throws -> Void

    /// Creates a client for a project's Firestore database.
    ///
    /// - Parameters:
    ///   - project: The project and database, or the Firestore emulator.
    ///   - credentials: How requests are authorized; ``Credentials/user(_:)`` for app users.
    ///   - transport: Sends the requests; tests pass their own.
    ///   - retryDelay: Waits before retry number 1 or 2 of a read, and before each new attempt
    ///     of a transaction (with 2 from the second retry on); tests pass a function that
    ///     returns at once.
    public init(
        project: FirebaseProject,
        credentials: Credentials = .none,
        transport: any HTTPTransport = URLSessionTransport(),
        retryDelay: @escaping @Sendable (Int) async throws -> Void = { attempt in
            try await Task.sleep(for: .milliseconds(250 << attempt))
        }
    ) {
        self.project = project
        self.credentials = credentials
        self.transport = transport
        self.retryDelay = retryDelay
    }

    // MARK: - Reading

    /// The document at `path`, such as `"notes/x7Gk2"`, or `nil` if it does not exist.
    public func document<Model: Decodable & Sendable>(_ path: String, as type: Model.Type) async throws -> FirestoreDocument<Model>? {
        let documentPath = try DocumentPath(path)
        do {
            let response = try await send(method: "GET", url: try url(for: documentPath.segments), idempotent: true)
            return try JSONBody.decode(RawDocument.self, from: response).decoded(as: type, root: project.documentsRoot)
        } catch let error as FirestoreError where error.code == .notFound {
            return nil
        }
    }

    /// One page of the documents in `collection`, ordered by ID.
    ///
    /// - Parameters:
    ///   - collection: A collection path, such as `"notes"` or `"users/ada/notes"`.
    ///   - type: The model to decode each document into.
    ///   - pageSize: 1 to 1,000.
    ///   - pageToken: ``FirestorePage/nextPageToken`` of the previous page, or `nil` for the first.
    public func documents<Model: Decodable & Sendable>(
        in collection: String,
        as type: Model.Type,
        pageSize: Int = 100,
        pageToken: String? = nil
    ) async throws -> FirestorePage<Model> {
        let collectionPath = try CollectionPath(collection)
        guard (1...1_000).contains(pageSize) else { throw ValidationError("pageSize", "must be from 1 to 1000") }
        var query = [URLQueryItem(name: "pageSize", value: String(pageSize))]
        if let pageToken { query.append(URLQueryItem(name: "pageToken", value: pageToken)) }
        let response = try await send(method: "GET", url: try url(for: collectionPath.segments, query: query), idempotent: true)
        let page = try JSONBody.decode(ListResponse.self, from: response)
        return FirestorePage(
            documents: try (page.documents ?? []).map { try $0.decoded(as: type, root: project.documentsRoot) },
            nextPageToken: page.nextPageToken?.isEmpty == false ? page.nextPageToken : nil
        )
    }

    /// The documents that match `query`, in its order.
    public func documents<Model: Decodable & Sendable>(matching query: FirestoreQuery, as type: Model.Type) async throws -> [FirestoreDocument<Model>] {
        let (parent, collectionID) = try query.target()
        let body = try JSONBody.encode(RunQueryBody(structuredQuery: try query.structuredQuery(collectionID: collectionID)))
        let url = try url(for: parent?.segments ?? [], suffix: ":runQuery")
        let response = try await send(method: "POST", url: url, body: body, idempotent: true)
        let results = try JSONBody.decode([RunQueryResult].self, from: response)
        return try results.compactMap(\.document).map { try $0.decoded(as: type, root: project.documentsRoot) }
    }

    // MARK: - Writing

    /// Adds a document with a new random ID to `collection` and returns its path.
    @discardableResult
    public func add(_ value: some Encodable, to collection: String, transforms: [FieldPath: FieldTransform] = [:]) async throws -> String {
        let path = try CollectionPath(collection).document(Self.newDocumentID()).description
        var batch = WriteBatch()
        try batch.create(value, at: path, transforms: transforms)
        try await commit(batch)
        return path
    }

    /// Writes the document at `path`, replacing it if it exists; see ``WriteBatch/set(_:at:merge:transforms:)``.
    public func set(_ value: some Encodable, at path: String, merge: Bool = false, transforms: [FieldPath: FieldTransform] = [:]) async throws {
        var batch = WriteBatch()
        try batch.set(value, at: path, merge: merge, transforms: transforms)
        try await commit(batch)
    }

    /// Changes fields of an existing document; see ``WriteBatch/update(_:fields:transforms:)``.
    public func update(_ path: String, fields: [FieldPath: FirestoreValue], transforms: [FieldPath: FieldTransform] = [:]) async throws {
        var batch = WriteBatch()
        try batch.update(path, fields: fields, transforms: transforms)
        try await commit(batch)
    }

    /// Deletes the document at `path`. Deleting a missing document succeeds.
    public func delete(_ path: String) async throws {
        var batch = WriteBatch()
        try batch.delete(path)
        try await commit(batch)
    }

    /// Applies the batch's writes atomically and returns the commit time.
    @discardableResult
    public func commit(_ batch: WriteBatch) async throws -> FirestoreTimestamp? {
        guard batch.count > 0 else { return nil }
        let body = try JSONBody.encode(CommitBody(writes: try batch.bodies(root: project.documentsRoot)))
        // Commits are not retried: with transforms such as increments, a commit whose answer was
        // lost may already have been applied.
        let response = try await send(method: "POST", url: try url(for: [], suffix: ":commit"), body: body, idempotent: false)
        return try JSONBody.decode(CommitResponse.self, from: response).commitTime.map(FirestoreTimestamp.init(rfc3339:))
    }

    /// A random 20-character ID like the ones the Firebase SDKs create.
    public static func newDocumentID() -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        var generator = SystemRandomNumberGenerator()
        return String((0..<20).map { _ in alphabet.randomElement(using: &generator)! })
    }
}

// MARK: - Requests

extension FirestoreClient {
    private static let maxRequestBytes = 10 * 1_048_576

    /// `.../documents/{segments}{suffix}`, with every document segment percent-encoded.
    func url(for segments: [String], suffix: String = "", query: [URLQueryItem] = []) throws -> URL {
        let base = project.firestoreEmulator.map { "\($0.baseURL)/v1/" } ?? "https://firestore.googleapis.com/v1/"
        let path = ([project.documentsRoot] + segments.map(PathRules.urlSegment)).joined(separator: "/")
        guard var components = URLComponents(string: base + path + suffix) else {
            throw ValidationError("Firestore URL", Redaction.path(path))
        }
        if !query.isEmpty {
            components.queryItems = query
            // URLComponents leaves "+" alone, and Google's servers read it as a space; page
            // tokens and transaction IDs are base64 and may contain one.
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
        guard let url = components.url else { throw ValidationError("Firestore URL", Redaction.path(path)) }
        return url
    }

    func send(method: String, url: URL, body: Data? = nil, idempotent: Bool) async throws -> HTTPResponse {
        if let body, body.count > Self.maxRequestBytes {
            throw ValidationError("request", "larger than Firestore's 10 MiB limit")
        }
        var attempt = 0
        var refreshedToken = false
        while true {
            let request = HTTPRequest(method: method, url: url, headers: try await headers(forceRefresh: refreshedToken), body: body)
            let response = try await transport.send(request)
            if (200..<300).contains(response.statusCode) { return response }
            let error = FirestoreError.from(response)
            if error.code == .unauthenticated, !refreshedToken, case .user = credentials {
                refreshedToken = true
                continue
            }
            guard idempotent, error.code.isTransient, attempt < 2 else { throw error }
            attempt += 1
            try await retryDelay(attempt)
        }
    }

    private func headers(forceRefresh: Bool) async throws -> [String: String] {
        var headers = ["Content-Type": "application/json"]
        switch credentials {
        case .none:
            break
        case let .user(auth):
            headers["Authorization"] = "Bearer \(try await auth.idToken(forceRefresh: forceRefresh).revealed)"
        case let .bearer(token):
            headers["Authorization"] = "Bearer \(try await token())"
        case .emulatorOwner:
            headers["Authorization"] = "Bearer owner"
        }
        if let bundleID = project.bundleID { headers["X-Ios-Bundle-Identifier"] = bundleID }
        return headers
    }
}

private struct ListResponse: Decodable {
    let documents: [RawDocument]?
    let nextPageToken: String?
}

private struct RunQueryBody: Encodable {
    let structuredQuery: StructuredQuery
}

private struct RunQueryResult: Decodable {
    let document: RawDocument?
}

private struct CommitBody: Encodable {
    let writes: [WriteBody]
}

private struct CommitResponse: Decodable {
    let commitTime: String?
}
