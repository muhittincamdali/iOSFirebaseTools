import Foundation

/// The claims of a Firebase ID token.
public struct IDTokenClaims: Sendable, Hashable, Decodable {
    /// `iss`: `https://securetoken.google.com/<project ID>`.
    public let issuer: String
    /// `aud`: the project ID.
    public let audience: String
    /// `sub`: the user's ID.
    public let subject: String
    /// `iat`.
    public let issuedAt: Date
    /// `exp`.
    public let expiresAt: Date
    /// `auth_time`: when the user signed in, which a refresh does not change.
    public let authenticatedAt: Date
    public let email: String?
    public let emailVerified: Bool
    /// `firebase.sign_in_provider`, such as `password`, `anonymous` or `apple.com`.
    public let signInProvider: String?
    /// Every claim, including the custom claims set with the Admin SDK.
    public let all: [String: JSONValue]

    /// A custom claim, such as `claims["admin"] == true`.
    public subscript(claim: String) -> JSONValue? { all[claim] }

    public init(from decoder: any Decoder) throws {
        let all = try decoder.singleValueContainer().decode([String: JSONValue].self)
        func string(_ key: String) throws -> String {
            guard case let .string(value)? = all[key] else { throw TokenError.malformed("missing \"\(key)\"") }
            return value
        }
        issuer = try string("iss")
        // RFC 7519 allows an array; Firebase sends one project ID as a string.
        guard case let .string(audience)? = all["aud"] else {
            throw TokenError.malformed("\"aud\" is not a single project ID")
        }
        self.audience = audience
        subject = try string("sub")
        issuedAt = try Self.numericDate(all["iat"], name: "iat")
        expiresAt = try Self.numericDate(all["exp"], name: "exp")
        authenticatedAt = try Self.numericDate(all["auth_time"], name: "auth_time")
        if case let .string(email)? = all["email"] { self.email = email } else { email = nil }
        emailVerified = all["email_verified"] == .bool(true)
        if case let .object(firebase)? = all["firebase"], case let .string(provider)? = firebase["sign_in_provider"] {
            signInProvider = provider
        } else {
            signInProvider = nil
        }
        self.all = all
    }

    // NumericDate (RFC 7519): seconds since 1970. Rejecting values outside years 1970–9999 keeps
    // every later date comparison and conversion in range.
    static func numericDate(_ value: JSONValue?, name: String) throws -> Date {
        guard case let .number(seconds)? = value, seconds.isFinite, (0...253_402_300_799).contains(seconds) else {
            throw TokenError.malformed("\"\(name)\" is not a date in seconds")
        }
        return Date(timeIntervalSince1970: seconds)
    }
}

/// Why a token was rejected.
public enum TokenError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The token is not a well-formed JWT with the claims of a Firebase ID token.
    case malformed(String)
    /// `alg` is not `RS256` (or `none` for a verifier made with ``IDTokenVerifier/emulator(projectID:clock:)``).
    case unsupportedAlgorithm(String)
    /// No published key has the token's `kid`.
    case unknownKey(String?)
    case invalidSignature
    case expired(Date)
    /// `iat` or `auth_time` is in the future.
    case notYetValid
    case wrongAudience(String)
    case wrongIssuer(String)
    case emptySubject
    /// Google's public keys could not be fetched or read.
    case keysUnavailable(String)

    public var description: String {
        switch self {
        case let .malformed(reason): "Malformed token: \(reason)"
        case let .unsupportedAlgorithm(alg): "Unsupported token algorithm \(alg)"
        case let .unknownKey(kid): "No public key with kid \(kid ?? "(none)")"
        case .invalidSignature: "The token signature is not valid"
        case let .expired(date): "The token expired at \(date)"
        case .notYetValid: "The token was issued in the future"
        case let .wrongAudience(aud): "The token is for project \(aud)"
        case let .wrongIssuer(iss): "The token was issued by \(iss)"
        case .emptySubject: "The token has no user ID"
        case let .keysUnavailable(reason): "Public keys unavailable: \(reason)"
        }
    }
}
