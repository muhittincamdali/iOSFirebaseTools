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

// Requests carry ID tokens, refresh tokens and passwords, and responses carry new tokens. A
// transport that logs them must not leak those, so the text forms follow `RedactionPolicy`:
// no body, no URL user info or fragment, query values and ID-like path segments hidden, and
// header values kept for an allowlist only.
extension HTTPRequest: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// The request as text for a log, with what ``RedactionPolicy`` hides replaced:
    ///
    /// ```text
    /// HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
    ///   headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
    ///   body: [body omitted: 112 bytes, application/x-www-form-urlencoded])
    /// ```
    public func redactedDescription(_ policy: RedactionPolicy = .default) -> String {
        "HTTPRequest(\(Redaction.method(method)) \(Redaction.url(url, policy: policy)), "
            + "headers: \(Redaction.headers(headers, policy: policy)), body: \(Redaction.body(body, headers: headers)))"
    }

    public var description: String { redactedDescription() }

    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: [
            "method": Redaction.method(method),
            "url": Redaction.url(url, policy: .default),
            "headers": Redaction.headers(headers, policy: .default),
            "body": Redaction.body(body, headers: headers),
        ], displayStyle: .struct)
    }
}

extension HTTPResponse: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// The response as text for a log; the body is never shown.
    public func redactedDescription(_ policy: RedactionPolicy = .default) -> String {
        "HTTPResponse(\(statusCode), headers: \(Redaction.headers(headers, policy: policy)), "
            + "body: \(Redaction.body(body, headers: headers)))"
    }

    public var description: String { redactedDescription() }

    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: [
            "statusCode": statusCode,
            "headers": Redaction.headers(headers, policy: .default),
            "body": Redaction.body(body, headers: headers),
        ], displayStyle: .struct)
    }
}

/// Sends the clients' requests. ``URLSessionTransport`` is the default; tests and previews
/// pass their own implementation to answer without a network.
public protocol HTTPTransport: Sendable {
    func send(_ request: HTTPRequest) async throws -> HTTPResponse
}

/// A transport failure that is not an answer from Firebase.
///
/// ``URLSessionTransport`` throws this instead of `URLError`: a `URLError` keeps the request URL
/// in `failingURL` and its `userInfo`, and Firebase request URLs carry the API key (`?key=`) and
/// document IDs, which `print(error)` and crash reports would show.
public enum TransportError: Error, Sendable, Hashable {
    /// The response body was larger than the transport's limit.
    case responseTooLarge(limit: Int)
    /// The system returned something other than an HTTP response.
    case notHTTP
    /// The request failed before Firebase answered: no connection, a timeout, a TLS failure.
    /// The code is the `URLError` code, such as `.notConnectedToInternet` or `.cannotConnectToHost`.
    case network(URLError.Code)
}

/// Sends requests with `URLSession` and stops reading a response that grows past a limit, so a
/// misbehaving server or proxy cannot make the app hold an unbounded body in memory.
///
/// A failed connection throws ``TransportError/network(_:)`` with the `URLError` code, never
/// the `URLError`, so the request URL and its API key stay out of the error.
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
        do {
            return try await load(request)
        } catch let error as URLError {
            // Only the code: the URLError itself holds the request URL with the API key.
            throw TransportError.network(error.code)
        }
    }

    private func load(_ request: HTTPRequest) async throws -> HTTPResponse {
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
