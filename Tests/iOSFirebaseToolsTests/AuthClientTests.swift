import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Authentication client")
struct AuthClientTests {
    let clock = TestClock()

    func makeClient(_ transport: MockTransport, store: InMemorySessionStore = InMemorySessionStore(), bundleID: String? = nil) throws -> FirebaseAuthClient {
        FirebaseAuthClient(project: try Fixtures.project(bundleID: bundleID), transport: transport, store: store, clock: clock.function)
    }

    @Test("Sign-up sends the documented request and returns a session")
    func signUpRequest() async throws {
        let transport = MockTransport { _, _ in Fixtures.signInResponse() }
        let client = try makeClient(transport, bundleID: "com.example.notes")
        let session = try await client.signUp(email: "ada@example.com", password: "correct horse")

        let request = try #require(transport.requests.first)
        #expect(request.method == "POST")
        #expect(request.url.absoluteString == "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyFixtureKey000000000000000000000")
        #expect(request.headers["X-Ios-Bundle-Identifier"] == "com.example.notes")
        #expect(request.jsonBody["email"] as? String == "ada@example.com")
        #expect(request.jsonBody["password"] as? String == "correct horse")
        #expect(request.jsonBody["returnSecureToken"] as? Bool == true)
        #expect(session.userID == "user-1")
        #expect(session.idToken.revealed == "id-token-1")
        #expect(session.expiresAt == clock.now.addingTimeInterval(3600))
        #expect(await client.session == session)
    }

    @Test("The emulator gets the same paths under its host")
    func emulatorURLs() async throws {
        let transport = MockTransport { request, _ in
            request.url.path.hasSuffix("/token") ? Fixtures.refreshResponse(userID: "anon") : Fixtures.signInResponse(userID: "anon", email: nil)
        }
        let project = try Fixtures.project().usingEmulators(auth: "127.0.0.1:9099", firestore: nil)
        let client = FirebaseAuthClient(project: project, transport: transport, store: InMemorySessionStore(), clock: clock.function)
        let session = try await client.signInAnonymously()
        _ = try await client.idToken(forceRefresh: true)

        #expect(session.isAnonymous)
        #expect(session.email == nil)
        #expect(transport.requests[0].url.absoluteString.hasPrefix("http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key="))
        #expect(transport.requests[0].jsonBody.keys.sorted() == ["returnSecureToken"])
        #expect(transport.requests[1].url.absoluteString.hasPrefix("http://127.0.0.1:9099/securetoken.googleapis.com/v1/token?key="))
    }

    @Test("Server error messages map to codes", arguments: [
        ("EMAIL_EXISTS", AuthError.Code.emailExists),
        ("WEAK_PASSWORD : Password should be at least 6 characters", .weakPassword),
        ("INVALID_LOGIN_CREDENTIALS", .invalidLoginCredentials),
        ("TOO_MANY_ATTEMPTS_TRY_LATER : Access to this account has been temporarily disabled", .tooManyAttempts),
        ("API key not valid. Please pass a valid API key.", .invalidAPIKey),
        ("SOMETHING_NEW", .other("SOMETHING_NEW")),
    ])
    func mapsErrors(_ message: String, _ code: AuthError.Code) async throws {
        let client = try makeClient(MockTransport { _, _ in .googleError(400, message: message) })
        let error = await #expect(throws: AuthError.self) { try await client.signIn(email: "ada@example.com", password: "pw") }
        #expect(error?.code == code)
        #expect(error?.statusCode == 400)
        #expect(await client.session == nil)
    }

    @Test("A non-JSON error body still gives an AuthError")
    func unreadableErrorBody() async throws {
        let client = try makeClient(MockTransport { _, _ in HTTPResponse(statusCode: 502, body: Data("<html>".utf8)) })
        let error = await #expect(throws: AuthError.self) { try await client.signInAnonymously() }
        #expect(error?.message == "HTTP 502")
    }

    @Test("Token lifetimes that are not 1–86400 decimal seconds are rejected without trapping", arguments: [
        "", "0", "-1", "NaN", "inf", "1e400", "3600.5", "99999999999999999999999", "86401", " 3600", "٣٦٠٠",
    ])
    func rejectsLifetimes(_ expiresIn: String) async throws {
        let client = try makeClient(MockTransport { _, _ in Fixtures.signInResponse(expiresIn: expiresIn) })
        await #expect(throws: MalformedResponseError.self) { try await client.signInAnonymously() }
        #expect(await client.session == nil)
    }

    @Test("E-mail and password are checked before any request", arguments: [
        ("", "pw"), ("no-at-sign", "pw"), ("a b@example.com", "pw"), ("ada@example.com\n", "pw"),
        (String(repeating: "a", count: 250) + "@x.co", "pw"), ("ada@example.com", ""),
        ("ada@example.com", String(repeating: "p", count: 4_097)),
    ])
    func checksCredentials(_ email: String, _ password: String) async throws {
        let transport = MockTransport { _, _ in Fixtures.signInResponse() }
        let client = try makeClient(transport)
        await #expect(throws: ValidationError.self) { try await client.signIn(email: email, password: password) }
        #expect(transport.requests.isEmpty)
    }

    @Test("A fresh token is returned without a request; a token near expiry is refreshed")
    func refreshesNearExpiry() async throws {
        let transport = MockTransport { request, _ in
            request.url.path.hasSuffix("/token") ? Fixtures.refreshResponse() : Fixtures.signInResponse()
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        #expect(try await client.idToken().revealed == "id-token-1")
        #expect(transport.requests.count == 1)

        clock.advance(by: 3_600 - 299)
        #expect(try await client.idToken().revealed == "id-token-2")
        #expect(transport.requests.count == 2)
        #expect(transport.requests[1].headers["Content-Type"] == "application/x-www-form-urlencoded")
        #expect(transport.requests[1].bodyText == "grant_type=refresh_token&refresh_token=refresh-token-1")
        #expect(await client.session?.refreshToken.revealed == "refresh-token-2")
    }

    @Test("Concurrent token requests share one refresh")
    func coalescesRefreshes() async throws {
        let transport = MockTransport { request, _ in
            guard request.url.path.hasSuffix("/token") else { return Fixtures.signInResponse() }
            try await Task.sleep(for: .milliseconds(50))
            return Fixtures.refreshResponse()
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<20 { group.addTask { try await client.idToken(forceRefresh: true).revealed } }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        #expect(Set(tokens) == ["id-token-2"])
        #expect(transport.requests.filter { $0.url.path.hasSuffix("/token") }.count == 1)
    }

    @Test("A refresh token with + & = characters is form-encoded")
    func formEncodesRefreshToken() async throws {
        let transport = MockTransport { request, _ in
            request.url.path.hasSuffix("/token") ? Fixtures.refreshResponse() : Fixtures.signInResponse(refreshToken: "a+b&c=d/e")
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        _ = try await client.idToken(forceRefresh: true)
        #expect(transport.requests[1].bodyText == "grant_type=refresh_token&refresh_token=a%2Bb%26c%3Dd/e")
    }

    @Test("A revoked refresh token signs the user out; a network failure does not")
    func revokedRefreshSignsOut() async throws {
        let store = InMemorySessionStore()
        let failNetwork = TestFlag()
        let transport = MockTransport { request, _ in
            guard request.url.path.hasSuffix("/token") else { return Fixtures.signInResponse() }
            if failNetwork.isSet { throw URLError(.notConnectedToInternet) }
            return .googleError(400, message: "TOKEN_EXPIRED", code: "INVALID_ARGUMENT")
        }
        let client = try makeClient(transport, store: store)
        try await client.signIn(email: "ada@example.com", password: "pw")

        failNetwork.set()
        await #expect(throws: URLError.self) { try await client.idToken(forceRefresh: true) }
        #expect(await client.session != nil)

        failNetwork.clear()
        let error = await #expect(throws: AuthError.self) { try await client.idToken(forceRefresh: true) }
        #expect(error?.requiresSignIn == true)
        #expect(await client.session == nil)
        #expect(await store.load() == nil)
        let notSignedIn = await #expect(throws: AuthError.self) { try await client.idToken() }
        #expect(notSignedIn?.code == .notSignedIn)
    }

    @Test("Signing out during a refresh does not bring the session back")
    func signOutWinsOverRefresh() async throws {
        let gate = AsyncGate()
        let transport = MockTransport { request, _ in
            guard request.url.path.hasSuffix("/token") else { return Fixtures.signInResponse() }
            await gate.wait()
            return Fixtures.refreshResponse()
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        let refresh = Task { try await client.idToken(forceRefresh: true) }
        while transport.requests.count < 2 { await Task.yield() }
        try await client.signOut()
        await gate.open()
        _ = try await refresh.value
        #expect(await client.session == nil)
    }

    @Test("The next user's token request does not join a refresh still running for the previous user")
    func nextUserGetsOwnRefresh() async throws {
        let gate = AsyncGate()
        let transport = MockTransport { request, _ in
            guard request.url.path.hasSuffix("/token") else {
                let email = request.jsonBody["email"] as? String ?? ""
                return email.hasPrefix("ada")
                    ? Fixtures.signInResponse(userID: "user-A", idToken: "A-1", refreshToken: "refresh-A")
                    : Fixtures.signInResponse(userID: "user-B", idToken: "B-1", refreshToken: "refresh-B")
            }
            guard request.bodyText.hasSuffix("refresh-B") else {
                await gate.wait()
                return Fixtures.refreshResponse(userID: "user-A", idToken: "A-2")
            }
            return Fixtures.refreshResponse(userID: "user-B", idToken: "B-2")
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        let refreshForA = Task { try await client.idToken(forceRefresh: true) }
        while transport.requests.count < 2 { await Task.yield() }
        try await client.signOut()
        try await client.signIn(email: "bob@example.com", password: "pw")

        let tokenForB = Task { try await client.idToken(forceRefresh: true) }
        // B's refresh is the fourth request. Bounded, so a B that joined A's refresh fails below
        // instead of hanging here.
        for _ in 0..<1_000 where transport.requests.count < 4 { await Task.yield() }
        await gate.open()
        #expect(try await tokenForB.value.revealed == "B-2")
        #expect(try await refreshForA.value.revealed == "A-2")
        #expect(await client.session?.userID == "user-B")
        #expect(await client.session?.idToken.revealed == "B-2")
    }

    @Test("A refresh answered for another user is rejected")
    func rejectsForeignRefresh() async throws {
        let transport = MockTransport { request, _ in
            request.url.path.hasSuffix("/token") ? Fixtures.refreshResponse(userID: "someone-else") : Fixtures.signInResponse()
        }
        let client = try makeClient(transport)
        try await client.signIn(email: "ada@example.com", password: "pw")
        await #expect(throws: MalformedResponseError.self) { try await client.idToken(forceRefresh: true) }
        #expect(await client.session?.idToken.revealed == "id-token-1")
    }

    @Test("A saved session is restored once and observers see every change")
    func restoresAndPublishes() async throws {
        let saved = AuthSession(userID: "saved", email: nil, isAnonymous: true, idToken: Secret("t"),
                                refreshToken: Secret("r"), expiresAt: clock.now.addingTimeInterval(3_600))
        let store = InMemorySessionStore(session: saved)
        let client = try makeClient(MockTransport { _, _ in Fixtures.signInResponse() }, store: store)
        let updates = await client.sessionUpdates()
        var iterator = updates.makeAsyncIterator()
        #expect(await iterator.next() == .some(nil))

        #expect(try await client.restoreSession() == saved)
        #expect(await iterator.next() == .some(saved))

        try await client.signIn(email: "ada@example.com", password: "pw")
        #expect(await iterator.next()??.userID == "user-1")
        #expect(await store.load()?.userID == "user-1")

        try await client.signOut()
        #expect(await iterator.next() == .some(nil))
        #expect(try await client.restoreSession() == nil)
    }

    @Test("Concurrent restores read the store once, and a sign-in during the read wins")
    func restoreRaces() async throws {
        let saved = AuthSession(userID: "saved", email: nil, isAnonymous: true, idToken: Secret("t"),
                                refreshToken: Secret("r"), expiresAt: clock.now.addingTimeInterval(3_600))
        let store = SlowStore(session: saved)
        let racing = FirebaseAuthClient(project: try Fixtures.project(), transport: MockTransport { _, _ in Fixtures.signInResponse() },
                                        store: store, clock: clock.function)
        async let first = racing.restoreSession()
        async let second = racing.restoreSession()
        let results = try await [first, second]
        #expect(results.map { $0?.userID } == ["saved", "saved"])
        #expect(await store.loads == 1)

        let fresh = FirebaseAuthClient(project: try Fixtures.project(), transport: MockTransport { _, _ in Fixtures.signInResponse() },
                                       store: SlowStore(session: saved), clock: clock.function)
        let restoring = Task { try await fresh.restoreSession() }
        try await Task.sleep(for: .milliseconds(10))
        try await fresh.signIn(email: "ada@example.com", password: "pw")
        _ = try await restoring.value
        #expect(await fresh.session?.userID == "user-1")
    }

    @Test("A password reset locale cannot carry header text")
    func checksLocale() async throws {
        let transport = MockTransport { _, _ in .json("{}") }
        let client = try makeClient(transport)
        await #expect(throws: ValidationError.self) { try await client.sendPasswordReset(to: "ada@example.com", locale: "en\r\nX-Evil: 1") }
        await #expect(throws: ValidationError.self) { try await client.sendPasswordReset(to: "ada@example.com", locale: "") }
        #expect(transport.requests.isEmpty)
        try await client.sendPasswordReset(to: "ada@example.com", locale: "pt-BR")
    }

    @Test("Password reset and account deletion send the documented bodies")
    func resetAndDelete() async throws {
        let transport = MockTransport { request, _ in
            request.url.path.hasSuffix("signInWithPassword") ? Fixtures.signInResponse() : .json("{}")
        }
        let client = try makeClient(transport)
        try await client.sendPasswordReset(to: "ada@example.com", locale: "tr")
        #expect(transport.requests[0].url.path.hasSuffix("accounts:sendOobCode"))
        #expect(transport.requests[0].jsonBody["requestType"] as? String == "PASSWORD_RESET")
        #expect(transport.requests[0].headers["X-Firebase-Locale"] == "tr")

        try await client.signIn(email: "ada@example.com", password: "pw")
        try await client.deleteAccount()
        #expect(transport.requests[2].url.path.hasSuffix("accounts:delete"))
        #expect(transport.requests[2].jsonBody["idToken"] as? String == "id-token-1")
        #expect(await client.session == nil)
    }
}

/// A flag shared with a transport handler.
final class TestFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    var isSet: Bool { lock.withLock { value } }
    func set() { lock.withLock { value = true } }
    func clear() { lock.withLock { value = false } }
}

/// Holds callers until it is opened.
actor AsyncGate {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if isOpen { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func open() {
        isOpen = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }
}

/// A store whose reads take a moment, to race restores against sign-ins.
actor SlowStore: SessionStore {
    private var session: AuthSession?
    private(set) var loads = 0

    init(session: AuthSession?) {
        self.session = session
    }

    func load() async throws -> AuthSession? {
        loads += 1
        let snapshot = session // what the keychain held when the read started
        try await Task.sleep(for: .milliseconds(100))
        return snapshot
    }

    func save(_ session: AuthSession) { self.session = session }
    func clear() { session = nil }
}
