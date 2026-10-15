import Foundation

/// A signed-in user: who it is and the tokens that prove it.
///
/// Printing a session shows the user and expiry, never the tokens:
///
/// ```text
/// AuthSession(user: 6kkpCpjp8Z…, email: ada@example.com, anonymous: false, expires: 2026-10-15 10:41:00 +0000)
/// ```
public struct AuthSession: Sendable, Hashable, Codable {
    /// The user's ID (`localId`), the `request.auth.uid` of Security Rules.
    public let userID: String
    /// The e-mail address, or `nil` for an anonymous user.
    public let email: String?
    /// `true` for a user created with ``FirebaseAuthClient/signInAnonymously()``.
    public let isAnonymous: Bool
    /// The Firebase ID token sent to Firestore and to your own servers. It is valid for an hour.
    public let idToken: Secret
    /// Exchanges for a new ID token. It stays valid until the user is disabled, deleted or
    /// changes their password.
    public let refreshToken: Secret
    /// When ``idToken`` expires.
    public let expiresAt: Date

    public init(userID: String, email: String?, isAnonymous: Bool, idToken: Secret, refreshToken: Secret, expiresAt: Date) {
        self.userID = userID
        self.email = email
        self.isAnonymous = isAnonymous
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    /// `true` when the ID token expires within `margin` of `date`.
    public func needsRefresh(at date: Date, margin: TimeInterval = 300) -> Bool {
        expiresAt.timeIntervalSince(date) <= margin
    }

    /// The claims of ``idToken``, read without verifying the signature. Use them on the device
    /// to show state; servers verify tokens with ``IDTokenVerifier``.
    public func unverifiedClaims() throws -> IDTokenClaims {
        try JSONWebToken(idToken.revealed).claims()
    }
}

extension AuthSession: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let user = userID.count > 10 ? "\(userID.prefix(10))…" : userID
        return "AuthSession(user: \(user), email: \(email ?? "none"), anonymous: \(isAnonymous), expires: \(expiresAt))"
    }

    public var debugDescription: String { description }
}

/// Keeps the session between launches. ``KeychainSessionStore`` is the one for apps;
/// ``InMemorySessionStore`` forgets the session when the process ends.
public protocol SessionStore: Sendable {
    func load() async throws -> AuthSession?
    func save(_ session: AuthSession) async throws
    func clear() async throws
}

/// A ``SessionStore`` that keeps the session in memory only.
public actor InMemorySessionStore: SessionStore {
    private var session: AuthSession?

    public init(session: AuthSession? = nil) {
        self.session = session
    }

    public func load() -> AuthSession? { session }

    public func save(_ session: AuthSession) { self.session = session }

    public func clear() { session = nil }
}
