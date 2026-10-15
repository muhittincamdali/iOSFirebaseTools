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

    public var description: String { "AuthError(\(code)): \(message)" }

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
