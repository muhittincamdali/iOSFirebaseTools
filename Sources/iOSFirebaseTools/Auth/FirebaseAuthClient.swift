import Foundation

/// Signs users in with Firebase Authentication over its REST API and keeps their ID token fresh.
///
/// ```swift
/// let auth = FirebaseAuthClient(project: project)
/// let session = try await auth.signIn(email: "ada@example.com", password: "correct horse")
/// let token = try await auth.idToken() // refreshed when it expires within 5 minutes
/// ```
///
/// The client is an actor: calls run one at a time, and concurrent ``idToken(forceRefresh:)``
/// calls share a single refresh request. Sessions are saved in a ``SessionStore`` (the keychain
/// by default) and restored by ``restoreSession()``.
public actor FirebaseAuthClient {
    public nonisolated let project: FirebaseProject
    private let endpoints: AuthEndpoints
    private let transport: any HTTPTransport
    private let store: any SessionStore
    private let clock: @Sendable () -> Date
    private var current: AuthSession?
    private var restored = false
    // Changes on every sign-in and sign-out, so a refresh that finishes later cannot bring back
    // a session the user left.
    private var generation = 0
    private var refreshTask: Task<AuthSession, any Error>?
    private var observers: [UUID: AsyncStream<AuthSession?>.Continuation] = [:]

    /// - Parameters:
    ///   - store: Where the session is kept between launches. Defaults to the keychain, with the
    ///     project ID as the account.
    ///   - clock: The current time; tests pass a fixed clock.
    public init(
        project: FirebaseProject,
        transport: any HTTPTransport = URLSessionTransport(),
        store: (any SessionStore)? = nil,
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.project = project
        self.endpoints = AuthEndpoints(project: project)
        self.transport = transport
        self.store = store ?? KeychainSessionStore(account: project.projectID)
        self.clock = clock
    }

    // MARK: - State

    /// Loads the saved session, once per client. Call it when the app starts.
    @discardableResult
    public func restoreSession() async throws -> AuthSession? {
        if !restored {
            restored = true
            if current == nil, let saved = try await store.load() {
                current = saved
                notify()
            }
        }
        return current
    }

    /// The signed-in user, or `nil`. The ID token in it may have expired; use
    /// ``idToken(forceRefresh:)`` for a token to send.
    public var session: AuthSession? { current }

    /// The current session now and after every change, until the task iterating it ends.
    public func sessionUpdates() -> AsyncStream<AuthSession?> {
        let (stream, continuation) = AsyncStream.makeStream(of: AuthSession?.self, bufferingPolicy: .bufferingNewest(1))
        let id = UUID()
        observers[id] = continuation
        continuation.yield(current)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id) }
        }
        return stream
    }

    // MARK: - Signing in and out

    /// Creates an account with an e-mail address and password and signs it in.
    @discardableResult
    public func signUp(email: String, password: String) async throws -> AuthSession {
        try Self.checkCredentials(email: email, password: password)
        let body = AuthBodies.Credentials(email: email, password: password)
        return try await startSession(endpoints.identityToolkit(.signUp, body: body), anonymous: false)
    }

    /// Signs in with an e-mail address and password.
    @discardableResult
    public func signIn(email: String, password: String) async throws -> AuthSession {
        try Self.checkCredentials(email: email, password: password)
        let body = AuthBodies.Credentials(email: email, password: password)
        return try await startSession(endpoints.identityToolkit(.signInWithPassword, body: body), anonymous: false)
    }

    /// Creates an anonymous user and signs it in. Anonymous sign-in must be enabled in the
    /// Firebase console.
    @discardableResult
    public func signInAnonymously() async throws -> AuthSession {
        try await startSession(endpoints.identityToolkit(.signUp, body: AuthBodies.Credentials()), anonymous: true)
    }

    /// Sends a password reset e-mail.
    ///
    /// - Parameter locale: A language code such as `"de"` for the e-mail's language.
    public func sendPasswordReset(to email: String, locale: String? = nil) async throws {
        try Self.checkEmail(email)
        let request = try endpoints.identityToolkit(.sendOobCode, body: AuthBodies.PasswordReset(email: email), locale: locale)
        _ = try await send(request)
    }

    /// Signs out on this device: forgets the session and removes it from the store.
    public func signOut() async throws {
        try await endSession()
    }

    /// Deletes the signed-in user's account and signs out.
    ///
    /// Firebase requires a recent sign-in; after an hour or so it answers
    /// ``AuthError/Code/tokenExpired`` and the user must sign in again first.
    public func deleteAccount() async throws {
        let token = try await idToken()
        _ = try await send(endpoints.identityToolkit(.delete, body: AuthBodies.IDTokenOnly(idToken: token.revealed)))
        try await endSession()
    }

    // MARK: - Tokens

    /// An ID token for the signed-in user, refreshed first if it expires within 5 minutes.
    ///
    /// Throws ``AuthError`` with ``AuthError/Code/notSignedIn`` without a session. When the
    /// refresh token is no longer accepted (the user was disabled or changed their password),
    /// the session is cleared and the error's ``AuthError/requiresSignIn`` is `true`.
    public func idToken(forceRefresh: Bool = false) async throws -> Secret {
        _ = try await restoreSession()
        guard let session = current else {
            throw AuthError(code: .notSignedIn, message: "No user is signed in")
        }
        if !forceRefresh && !session.needsRefresh(at: clock()) { return session.idToken }
        return try await refreshedSession().idToken
    }

    private func refreshedSession() async throws -> AuthSession {
        if let refreshTask { return try await refreshTask.value }
        let task = Task { try await self.performRefresh() }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }

    private func performRefresh() async throws -> AuthSession {
        guard let session = current else { throw AuthError(code: .notSignedIn, message: "No user is signed in") }
        let startedIn = generation
        let response: HTTPResponse
        do {
            response = try await send(endpoints.refresh(refreshToken: session.refreshToken))
        } catch let error as AuthError where error.requiresSignIn && generation == startedIn {
            try await endSession()
            throw error
        }
        let body = try JSONBody.decode(AuthBodies.RefreshResponse.self, from: response)
        guard body.user_id == session.userID else {
            throw MalformedResponseError(statusCode: response.statusCode, reason: "the refreshed token is for another user")
        }
        let refreshed = AuthSession(
            userID: session.userID, email: session.email, isAnonymous: session.isAnonymous,
            idToken: Secret(body.id_token), refreshToken: Secret(body.refresh_token),
            expiresAt: clock().addingTimeInterval(try AuthBodies.lifetime(body.expires_in, statusCode: response.statusCode))
        )
        // Signed out or in as someone else meanwhile: hand back the token but keep the new state.
        guard generation == startedIn else { return refreshed }
        try await adopt(refreshed)
        return refreshed
    }

    // MARK: - Helpers

    private func startSession(_ request: HTTPRequest, anonymous: Bool) async throws -> AuthSession {
        let response = try await send(request)
        let body = try JSONBody.decode(AuthBodies.SignInResponse.self, from: response)
        let session = AuthSession(
            userID: body.localId, email: body.email?.isEmpty == false ? body.email : nil, isAnonymous: anonymous,
            idToken: Secret(body.idToken), refreshToken: Secret(body.refreshToken),
            expiresAt: clock().addingTimeInterval(try AuthBodies.lifetime(body.expiresIn, statusCode: response.statusCode))
        )
        generation += 1
        restored = true
        try await adopt(session)
        return session
    }

    /// Keeps the session in memory and tells observers, then saves it. A store error is thrown
    /// after the session is already in use for this launch.
    private func adopt(_ session: AuthSession) async throws {
        current = session
        notify()
        try await store.save(session)
    }

    private func endSession() async throws {
        generation += 1
        restored = true
        current = nil
        notify()
        try await store.clear()
    }

    private func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        let response = try await transport.send(request)
        guard (200..<300).contains(response.statusCode) else { throw AuthError.from(response) }
        return response
    }

    private func notify() {
        for continuation in observers.values { continuation.yield(current) }
    }

    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }

    static func checkCredentials(email: String, password: String) throws {
        try checkEmail(email)
        guard !password.isEmpty, password.utf8Count <= Limits.maxPasswordBytes else {
            throw ValidationError("password", "must be 1–\(Limits.maxPasswordBytes) bytes")
        }
    }

    static func checkEmail(_ email: String) throws {
        guard email.utf8Count <= Limits.maxEmailBytes, email.contains("@"),
              !email.unicodeScalars.contains(where: { $0.properties.isWhitespace || $0.properties.generalCategory == .control }) else {
            throw ValidationError("email", "not an e-mail address")
        }
    }
}
