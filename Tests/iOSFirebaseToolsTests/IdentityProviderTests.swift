import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Identity provider sign-in")
struct IdentityProviderTests {
    func client(_ transport: MockTransport) throws -> FirebaseAuthClient {
        FirebaseAuthClient(project: try Fixtures.project(), transport: transport, store: InMemorySessionStore())
    }

    @Test("Sign in with Apple sends the token and raw nonce in signInWithIdp's postBody")
    func appleRequest() async throws {
        let transport = MockTransport { _, _ in Fixtures.signInResponse(userID: "apple-user", email: "x@privaterelay.appleid.com") }
        let session = try await client(transport).signIn(with: .apple(idToken: "eyJ.apple+token", rawNonce: "n&once="))
        #expect(session.userID == "apple-user")
        #expect(!session.isAnonymous)

        let request = try #require(transport.requests.first)
        #expect(request.url.path.hasSuffix("accounts:signInWithIdp"))
        #expect(request.jsonBody["postBody"] as? String == "providerId=apple.com&id_token=eyJ.apple%2Btoken&nonce=n%26once%3D")
        #expect(request.jsonBody["requestUri"] as? String == "http://localhost")
        #expect(request.jsonBody["returnSecureToken"] as? Bool == true)
    }

    @Test("Google and generic credentials, and their checks")
    func otherCredentials() throws {
        #expect(IdentityProviderCredential.google(idToken: "id", accessToken: "at").postBody
            == "providerId=google.com&id_token=id&access_token=at")
        #expect(try IdentityProviderCredential(providerID: "oidc.example", idToken: nil, accessToken: "at").postBody
            == "providerId=oidc.example&access_token=at")
        #expect(throws: ValidationError.self) { try IdentityProviderCredential(providerID: "apple.com", idToken: nil) }
        #expect(throws: ValidationError.self) { try IdentityProviderCredential(providerID: "evil&providerId=x", idToken: "t") }
        #expect(throws: ValidationError.self) { try IdentityProviderCredential(providerID: "", idToken: "t") }
    }

    @Test("A credential prints without its tokens")
    func redactsCredential() {
        let credential = IdentityProviderCredential.apple(idToken: "header.payload-secret.sig", rawNonce: "nonce-secret")
        var dumped = ""
        dump(credential, to: &dumped)
        for text in [String(describing: credential), String(reflecting: credential), dumped] {
            #expect(!text.contains("payload-secret") && !text.contains("nonce-secret"), "\(text)")
        }
    }

    @Test("An e-mail owned by another provider needs confirmation and is not signed in")
    func needsConfirmation() async throws {
        let transport = MockTransport { _, _ in
            .json(#"{"needConfirmation":true,"email":"ada@example.com","providerId":"google.com"}"#)
        }
        let auth = try client(transport)
        let error = await #expect(throws: AuthError.self) { try await auth.signIn(with: .google(idToken: "t")) }
        #expect(error?.code == .other("NEED_CONFIRMATION"))
        #expect(await auth.session == nil)
    }

    @Test("Apple nonces are random, 32 characters, and hashed with SHA-256")
    func nonces() {
        let nonces = (0..<100).map { _ in AppleSignInNonce() }
        #expect(Set(nonces.map(\.raw)).count == 100)
        let allowed = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        #expect(nonces.allSatisfy { $0.raw.count == 32 && $0.raw.allSatisfy(allowed.contains) })
        #expect(nonces[0].sha256.count == 64)
        #expect(AppleSignInNonce(raw: "abc").sha256 == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }
}
