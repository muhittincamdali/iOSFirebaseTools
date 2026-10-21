import Foundation

/// An error returned by Firebase Authentication, or a sign-in state the call needs.
public struct AuthError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The error codes of the Identity Toolkit and Secure Token APIs that apps handle.
    public enum Code: Sendable, Hashable {
        case emailExists
        case invalidEmail
        case weakPassword
        /// Wrong e-mail or password. Projects with e-mail enumeration protection (the default
        /// since 2023) return this instead of ``emailNotFound`` and ``invalidPassword``.
        case invalidLoginCredentials
        case emailNotFound
        case invalidPassword
        case userDisabled
        case userNotFound
        case tooManyAttempts
        case operationNotAllowed
        /// The user must sign in again, for example after a password change.
        case tokenExpired
        case invalidIDToken
        case invalidRefreshToken
        /// The API key is wrong, restricted to other apps or has the API disabled.
        case invalidAPIKey
        /// The refresh token belongs to another project than the API key.
        case projectNumberMismatch
        /// No user is signed in.
        case notSignedIn
        /// Any other code, as Firebase sent it.
        case other(String)

        init(serverCode: String) {
            switch serverCode {
            case "EMAIL_EXISTS": self = .emailExists
            case "INVALID_EMAIL", "MISSING_EMAIL": self = .invalidEmail
            case "WEAK_PASSWORD", "MISSING_PASSWORD": self = .weakPassword
            case "INVALID_LOGIN_CREDENTIALS": self = .invalidLoginCredentials
            case "EMAIL_NOT_FOUND": self = .emailNotFound
            case "INVALID_PASSWORD": self = .invalidPassword
            case "USER_DISABLED": self = .userDisabled
            case "USER_NOT_FOUND": self = .userNotFound
            case "TOO_MANY_ATTEMPTS_TRY_LATER": self = .tooManyAttempts
            case "OPERATION_NOT_ALLOWED", "ADMIN_ONLY_OPERATION": self = .operationNotAllowed
            case "TOKEN_EXPIRED", "CREDENTIAL_TOO_OLD_LOGIN_AGAIN": self = .tokenExpired
            case "INVALID_ID_TOKEN": self = .invalidIDToken
            case "INVALID_REFRESH_TOKEN", "MISSING_REFRESH_TOKEN", "INVALID_GRANT_TYPE": self = .invalidRefreshToken
            case "PROJECT_NUMBER_MISMATCH": self = .projectNumberMismatch
            default:
                self = serverCode.hasPrefix("API key not valid") || serverCode == "API_KEY_INVALID"
                    ? .invalidAPIKey : .other(serverCode)
            }
        }
    }

    public let code: Code
    /// The server's message, such as `WEAK_PASSWORD : Password should be at least 6 characters`.
    /// It is the server's free text and is not redacted, so ``description`` leaves it out; show
    /// it to a developer, not in a log.
    public let message: String
    /// The HTTP status, or `nil` for an error raised on the device.
    public let statusCode: Int?

    public init(code: Code, message: String, statusCode: Int? = nil) {
        self.code = code
        self.message = message
        self.statusCode = statusCode
    }

    /// `true` when the stored session can no longer be refreshed and the user must sign in again.
    public var requiresSignIn: Bool {
        switch code {
        case .tokenExpired, .invalidIDToken, .invalidRefreshToken, .userDisabled, .userNotFound,
             .projectNumberMismatch, .notSignedIn:
            true
        default:
            false
        }
    }

    /// The code and HTTP status, such as `AuthError(weakPassword, HTTP 400)`, without the
    /// server's message.
    public var description: String {
        "AuthError(\(code)" + (statusCode.map { ", HTTP \($0))" } ?? ")")
    }

    /// Reads the error body of a failed Identity Toolkit or Secure Token response.
    static func from(_ response: HTTPResponse) -> AuthError {
        let detail = GoogleAPIErrorBody.decode(response.body)
        // Kept short: the message ends up in logs and alerts.
        let message = String((detail?.message ?? "HTTP \(response.statusCode)").prefix(500))
        // Messages look like "WEAK_PASSWORD : Password should be at least 6 characters".
        let serverCode = message.components(separatedBy: " : ").first?
            .trimmingCharacters(in: .whitespaces) ?? message
        return AuthError(code: Code(serverCode: serverCode), message: message, statusCode: response.statusCode)
    }
}

// The message and an unknown code are the server's free text, which can repeat what the user
// typed. `dump`, `debugPrint` and the debugger see the same fields as `description`.
extension AuthError: CustomDebugStringConvertible, CustomReflectable {
    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: ["code": code.description, "statusCode": statusCode as Any], displayStyle: .struct)
    }
}

extension AuthError.Code: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// The case name, such as `weakPassword`. An ``other(_:)`` code is shown only when it looks
    /// like a server code such as `QUOTA_EXCEEDED`, and hidden with its length otherwise.
    public var description: String {
        switch self {
        case .emailExists: "emailExists"
        case .invalidEmail: "invalidEmail"
        case .weakPassword: "weakPassword"
        case .invalidLoginCredentials: "invalidLoginCredentials"
        case .emailNotFound: "emailNotFound"
        case .invalidPassword: "invalidPassword"
        case .userDisabled: "userDisabled"
        case .userNotFound: "userNotFound"
        case .tooManyAttempts: "tooManyAttempts"
        case .operationNotAllowed: "operationNotAllowed"
        case .tokenExpired: "tokenExpired"
        case .invalidIDToken: "invalidIDToken"
        case .invalidRefreshToken: "invalidRefreshToken"
        case .invalidAPIKey: "invalidAPIKey"
        case .projectNumberMismatch: "projectNumberMismatch"
        case .notSignedIn: "notSignedIn"
        case let .other(serverCode): "other(\(ErrorCodeText.render(serverCode)))"
        }
    }

    public var debugDescription: String { description }

    public var customMirror: Mirror { Mirror(self, children: [], displayStyle: .enum) }
}
