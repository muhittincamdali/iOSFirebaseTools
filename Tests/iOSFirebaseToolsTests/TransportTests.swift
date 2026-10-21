import Foundation
import Testing
@testable import iOSFirebaseTools

/// Serves canned bodies to a URLSession, so the real transport runs without a network.
final class StubProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var body = Data()
    nonisolated(unsafe) static var contentLength: String?
    nonisolated(unsafe) static var failure: URLError?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let failure = Self.failure {
            client?.urlProtocol(self, didFailWithError: failure)
            return
        }
        var headers = ["Content-Type": "application/json"]
        if let length = Self.contentLength { headers["Content-Length"] = length }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

@Suite("URLSession transport", .serialized)
struct TransportTests {
    func transport(limit: Int) -> URLSessionTransport {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubProtocol.self]
        return URLSessionTransport(session: URLSession(configuration: configuration), maxResponseBytes: limit)
    }

    @Test("A body within the limit is returned with lowercase headers")
    func returnsBody() async throws {
        StubProtocol.body = Data(#"{"ok":true}"#.utf8)
        StubProtocol.contentLength = nil
        let response = try await transport(limit: 1_024).send(HTTPRequest(method: "GET", url: URL(string: "https://example.com/a")!))
        #expect(response.statusCode == 200)
        #expect(response.body == StubProtocol.body)
        #expect(response.headers["content-type"] == "application/json")
    }

    @Test("A body past the limit stops the read, with or without Content-Length")
    func capsBody() async throws {
        StubProtocol.body = Data(count: 4_096)
        for length in [nil, "4096"] as [String?] {
            StubProtocol.contentLength = length
            await #expect(throws: TransportError.responseTooLarge(limit: 1_024)) {
                try await transport(limit: 1_024).send(HTTPRequest(method: "GET", url: URL(string: "https://example.com/b")!))
            }
        }
    }

    @Test("A connection failure throws the URLError code without the URL, its API key or IDs")
    func networkFailureHidesURL() async throws {
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/demo/databases/(default)/documents/notes/K3vXq9TzPlm2RwYb8NaC?key=AIzaSyA-0123456789abcdefghijklmnopqrstu")!
        StubProtocol.failure = URLError(.notConnectedToInternet, userInfo: [
            NSURLErrorFailingURLErrorKey: url, NSURLErrorFailingURLStringErrorKey: url.absoluteString,
        ])
        defer { StubProtocol.failure = nil }
        let error = try await #require(throws: TransportError.self) {
            try await transport(limit: 1_024).send(HTTPRequest(method: "GET", url: url))
        }
        #expect(error == .network(.notConnectedToInternet))
        var dumped = ""
        dump(error, to: &dumped)
        let nsError = error as NSError
        for text in [String(describing: error), String(reflecting: error), error.localizedDescription, dumped,
                     nsError.debugDescription, "\(nsError.userInfo)"] {
            for secret in ["AIzaSy", "K3vXq9TzPlm2RwYb8NaC", "key="] {
                #expect(!text.contains(secret), "\(text)")
            }
        }
    }
}
