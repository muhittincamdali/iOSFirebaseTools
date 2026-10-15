import Foundation

/// An HTTP request built by the clients.
public struct HTTPRequest: Sendable, Hashable {
    public var method: String
    public var url: URL
    public var headers: [String: String]
    public var body: Data?

    public init(method: String, url: URL, headers: [String: String] = [:], body: Data? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

/// An HTTP response handed back to the clients.
public struct HTTPResponse: Sendable, Hashable {
    public var statusCode: Int
    /// Header names in lowercase.
    public var headers: [String: String]
    public var body: Data

    public init(statusCode: Int, headers: [String: String] = [:], body: Data = Data()) {
        self.statusCode = statusCode
        self.headers = Dictionary(headers.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { $1 })
        self.body = body
    }
}

/// Sends the clients' requests. ``URLSessionTransport`` is the default; tests and previews
/// pass their own implementation to answer without a network.
public protocol HTTPTransport: Sendable {
    func send(_ request: HTTPRequest) async throws -> HTTPResponse
}

/// A transport failure that is not an answer from Firebase.
public enum TransportError: Error, Sendable, Hashable {
    /// The response body was larger than the transport's limit.
    case responseTooLarge(limit: Int)
    /// The system returned something other than an HTTP response.
    case notHTTP
}

/// Sends requests with `URLSession` and stops reading a response that grows past a limit, so a
/// misbehaving server or proxy cannot make the app hold an unbounded body in memory.
public struct URLSessionTransport: HTTPTransport {
    private let session: URLSession
    private let maxResponseBytes: Int

    /// - Parameters:
    ///   - session: Defaults to an ephemeral session, so no response is written to a disk cache.
    ///   - maxResponseBytes: Defaults to 16 MiB, enough for a page of 1 MiB documents.
    public init(session: URLSession = URLSession(configuration: .ephemeral), maxResponseBytes: Int = 16 * 1_048_576) {
        self.session = session
        self.maxResponseBytes = max(1, maxResponseBytes)
    }

    public func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        for (name, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        let (bytes, response) = try await session.bytes(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw TransportError.notHTTP }
        if http.expectedContentLength > Int64(maxResponseBytes) {
            bytes.task.cancel()
            throw TransportError.responseTooLarge(limit: maxResponseBytes)
        }
        var body = Data()
        for try await byte in bytes {
            guard body.count < maxResponseBytes else {
                bytes.task.cancel()
                throw TransportError.responseTooLarge(limit: maxResponseBytes)
            }
            body.append(byte)
        }
        var headers: [String: String] = [:]
        for (name, value) in http.allHeaderFields {
            if let name = name as? String, let value = value as? String { headers[name] = value }
        }
        return HTTPResponse(statusCode: http.statusCode, headers: headers, body: body)
    }
}
