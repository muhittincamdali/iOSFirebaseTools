import Foundation

/// An error returned by Cloud Firestore.
public struct FirestoreError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The canonical status codes Firestore uses.
    public enum Code: Sendable, Hashable {
        case invalidArgument
        case notFound
        case alreadyExists
        /// Security Rules denied the request.
        case permissionDenied
        /// No or an expired ID token.
        case unauthenticated
        /// A precondition failed, often a query that needs an index; the message has a link
        /// that creates it.
        case failedPrecondition
        case aborted
        case resourceExhausted
        case unavailable
        case deadlineExceeded
        case `internal`
        case other(String)

        init(status: String?, httpStatus: Int) {
            switch status {
            case "INVALID_ARGUMENT": self = .invalidArgument
            case "NOT_FOUND": self = .notFound
            case "ALREADY_EXISTS": self = .alreadyExists
            case "PERMISSION_DENIED": self = .permissionDenied
            case "UNAUTHENTICATED": self = .unauthenticated
            case "FAILED_PRECONDITION": self = .failedPrecondition
            case "ABORTED": self = .aborted
            case "RESOURCE_EXHAUSTED": self = .resourceExhausted
            case "UNAVAILABLE": self = .unavailable
            case "DEADLINE_EXCEEDED": self = .deadlineExceeded
            case "INTERNAL": self = .internal
            case let status?: self = .other(status)
            case nil: self = Self(httpStatus: httpStatus)
            }
        }

        private init(httpStatus: Int) {
            switch httpStatus {
            case 400: self = .invalidArgument
            case 401: self = .unauthenticated
            case 403: self = .permissionDenied
            case 404: self = .notFound
            case 409: self = .aborted
            case 429: self = .resourceExhausted
            case 503: self = .unavailable
            case 504: self = .deadlineExceeded
            default: self = .other("HTTP \(httpStatus)")
            }
        }

        /// Worth retrying after a pause: the request did not take effect.
        var isTransient: Bool {
            switch self {
            case .unavailable, .resourceExhausted, .deadlineExceeded, .aborted, .internal: true
            default: false
            }
        }
    }

    public let code: Code
    /// The server's message. For ``Code/failedPrecondition`` it often holds the link that
    /// creates a missing index. It is the server's free text and is not redacted, so
    /// ``description`` leaves it out.
    public let message: String
    public let statusCode: Int

    public init(code: Code, message: String, statusCode: Int) {
        self.code = code
        self.message = message
        self.statusCode = statusCode
    }

    /// The code and HTTP status, such as `FirestoreError(permissionDenied, HTTP 403)`, without
    /// the server's message.
    public var description: String {
        "FirestoreError(\(code), HTTP \(statusCode))"
    }

    static func from(_ response: HTTPResponse) -> FirestoreError {
        // runQuery reports errors inside a one-element array.
        let detail = GoogleAPIErrorBody.decode(response.body)
            ?? (try? JSONDecoder().decode([GoogleAPIErrorBody].self, from: response.body))?.first?.error
        let message = String((detail?.message ?? "HTTP \(response.statusCode)").prefix(500))
        return FirestoreError(code: Code(status: detail?.status, httpStatus: response.statusCode), message: message, statusCode: response.statusCode)
    }
}

// The message and an unknown status are the server's free text, which can name documents and
// values. `dump`, `debugPrint` and the debugger see the same fields as `description`.
extension FirestoreError: CustomDebugStringConvertible, CustomReflectable {
    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: ["code": code.description, "statusCode": statusCode], displayStyle: .struct)
    }
}

extension FirestoreError.Code: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// The case name, such as `permissionDenied`. An ``other(_:)`` status is shown only when it
    /// looks like a status such as `CANCELLED` or `HTTP 418`, and hidden with its length otherwise.
    public var description: String {
        switch self {
        case .invalidArgument: "invalidArgument"
        case .notFound: "notFound"
        case .alreadyExists: "alreadyExists"
        case .permissionDenied: "permissionDenied"
        case .unauthenticated: "unauthenticated"
        case .failedPrecondition: "failedPrecondition"
        case .aborted: "aborted"
        case .resourceExhausted: "resourceExhausted"
        case .unavailable: "unavailable"
        case .deadlineExceeded: "deadlineExceeded"
        case .internal: "internal"
        case let .other(status): "other(\(ErrorCodeText.render(status)))"
        }
    }

    public var debugDescription: String { description }

    public var customMirror: Mirror { Mirror(self, children: [], displayStyle: .enum) }
}
