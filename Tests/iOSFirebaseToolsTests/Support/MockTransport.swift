import Foundation
import iOSFirebaseTools

/// Answers requests with a handler and records them, so tests can check what was sent.
final class MockTransport: HTTPTransport, @unchecked Sendable {
    typealias Handler = @Sendable (HTTPRequest, Int) async throws -> HTTPResponse

    private let lock = NSLock()
    private var recorded: [HTTPRequest] = []
    private let handler: Handler

    /// - Parameter handler: Gets the request and its zero-based number.
    init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    /// Answers every request with the same status and JSON body.
    convenience init(status: Int = 200, json: String, headers: [String: String] = [:]) {
        self.init { _, _ in HTTPResponse(statusCode: status, headers: headers, body: Data(json.utf8)) }
    }

    var requests: [HTTPRequest] {
        lock.withLock { recorded }
    }

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        let number = lock.withLock {
            recorded.append(request)
            return recorded.count - 1
        }
        return try await handler(request, number)
    }
}

extension HTTPResponse {
    static func json(_ text: String, status: Int = 200, headers: [String: String] = [:]) -> HTTPResponse {
        HTTPResponse(statusCode: status, headers: headers, body: Data(text.utf8))
    }

    static func googleError(_ status: Int, message: String, code: String? = nil) -> HTTPResponse {
        let statusField = code.map { #","status":"\#($0)""# } ?? ""
        return .json(#"{"error":{"code":\#(status),"message":"\#(message)"\#(statusField)}}"#, status: status)
    }
}

extension HTTPRequest {
    /// The body parsed as a JSON object.
    var jsonBody: [String: Any] {
        guard let body, let object = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else { return [:] }
        return object
    }

    var bodyText: String { body.map { String(decoding: $0, as: UTF8.self) } ?? "" }
}

/// A clock that tests move by hand.
final class TestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var current: Date

    init(_ start: Date = Date(timeIntervalSince1970: 1_800_000_000)) {
        current = start
    }

    var now: Date { lock.withLock { current } }

    func advance(by seconds: TimeInterval) {
        lock.withLock { current = current.addingTimeInterval(seconds) }
    }

    var function: @Sendable () -> Date { { self.now } }
}

enum Fixtures {
    static func project(bundleID: String? = nil) throws -> FirebaseProject {
        try FirebaseProject(projectID: "demo-fixture", apiKey: "AIzaSyFixtureKey000000000000000000000", bundleID: bundleID)
    }

    /// An unsigned token like the Authentication emulator issues.
    static func unsignedToken(_ claims: [String: Any]) -> String {
        let header = Data(#"{"alg":"none","typ":"JWT"}"#.utf8)
        let payload = try! JSONSerialization.data(withJSONObject: claims, options: [.sortedKeys])
        return "\(base64URL(header)).\(base64URL(payload))."
    }

    static func base64URL(_ data: Data) -> String {
        data.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }

    static func signInResponse(userID: String = "user-1", email: String? = "ada@example.com", expiresIn: String = "3600",
                               idToken: String = "id-token-1", refreshToken: String = "refresh-token-1") -> HTTPResponse {
        let emailField = email.map { #","email":"\#($0)""# } ?? ""
        return .json(#"{"idToken":"\#(idToken)","refreshToken":"\#(refreshToken)","expiresIn":"\#(expiresIn)","localId":"\#(userID)"\#(emailField)}"#)
    }

    static func refreshResponse(userID: String = "user-1", idToken: String = "id-token-2", refreshToken: String = "refresh-token-2",
                                expiresIn: String = "3600") -> HTTPResponse {
        .json(#"{"id_token":"\#(idToken)","refresh_token":"\#(refreshToken)","expires_in":"\#(expiresIn)","user_id":"\#(userID)","token_type":"Bearer"}"#)
    }
}
