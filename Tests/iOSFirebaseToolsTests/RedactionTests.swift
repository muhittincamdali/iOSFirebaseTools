import Foundation
import Security
import Testing
@testable import iOSFirebaseTools

@Suite("Secrets never print")
struct RedactionTests {
    let token = "eyJhbGciOiJSUzI1NiJ9.c2VjcmV0LXBheWxvYWQ.c2lnbmF0dXJl"
    let refresh = "AMf-vBx-refresh-token-value"

    var session: AuthSession {
        AuthSession(userID: "6kkpCpjp8ZoLQh5pxcKdIGVzJWfr", email: "ada@example.com", isAnonymous: false,
                    idToken: Secret(token), refreshToken: Secret(refresh), expiresAt: Date(timeIntervalSince1970: 1_800_000_000))
    }

    /// Every way a value usually reaches a log.
    func renderings(of value: Any) -> [String] {
        var dumped = ""
        dump(value, to: &dumped)
        var debugPrinted = ""
        debugPrint(value, to: &debugPrinted)
        return [String(describing: value), String(reflecting: value), "\(value)", dumped, debugPrinted,
                Mirror(reflecting: value).children.map { "\($0.label ?? "") \($0.value)" }.joined()]
    }

    @Test("A Secret shows only its length")
    func secretIsRedacted() {
        let secret = Secret(token)
        for text in renderings(of: secret) {
            #expect(!text.contains("c2VjcmV0"), "\(text)")
        }
        #expect(secret.description == "Secret(redacted, \(token.count) characters)")
        #expect(secret.revealed == token)
    }

    @Test("A session shows the user but neither token")
    func sessionIsRedacted() {
        for text in renderings(of: session) {
            #expect(!text.contains("c2VjcmV0") && !text.contains("refresh-token-value"), "\(text)")
        }
        #expect(session.description.contains("6kkpCpjp8Z…"))
        #expect(!session.description.contains("6kkpCpjp8ZoLQh5pxcKdIGVzJWfr"))
    }

    @Test("Secrets inside collections and optionals stay redacted")
    func nestedSecretsAreRedacted() {
        let values: [Any] = [[session], ["key": Secret(token)], Optional(Secret(token)) as Any, (Secret(token), 1)]
        for value in values {
            for text in renderings(of: value) {
                #expect(!text.contains("c2VjcmV0"), "\(text)")
            }
        }
    }

    @Test("Codable keeps the full value for the keychain")
    func codableRoundTrip() throws {
        let data = try JSONEncoder().encode(session)
        #expect(try JSONDecoder().decode(AuthSession.self, from: data) == session)
    }
}

/// A test bundle on the iOS simulator has no keychain entitlement (errSecMissingEntitlement);
/// FirebaseLab's UI tests cover the store there, inside a signed app.
enum KeychainProbe {
    static var isAvailable: Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "iOSFirebaseTools.tests.probe",
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) != errSecMissingEntitlement
    }
}

@Suite("Keychain session store", .enabled(if: KeychainProbe.isAvailable))
struct KeychainSessionStoreTests {
    @Test("Saves, replaces, loads and clears a session")
    func roundTrip() async throws {
        let store = KeychainSessionStore(service: "iOSFirebaseTools.tests", account: UUID().uuidString)
        defer { Task { try? await store.clear() } }
        #expect(try await store.load() == nil)

        let first = AuthSession(userID: "u1", email: nil, isAnonymous: true, idToken: Secret("a"), refreshToken: Secret("b"),
                                expiresAt: Date(timeIntervalSince1970: 1_800_000_000))
        try await store.save(first)
        #expect(try await store.load() == first)

        let second = AuthSession(userID: "u2", email: "b@example.com", isAnonymous: false, idToken: Secret("c"),
                                 refreshToken: Secret("d"), expiresAt: Date(timeIntervalSince1970: 1_800_003_600))
        try await store.save(second)
        #expect(try await store.load() == second)

        try await store.clear()
        #expect(try await store.load() == nil)
        try await store.clear()
    }
}
