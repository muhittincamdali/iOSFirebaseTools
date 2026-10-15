import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("ID token verification")
struct TokenVerifierTests {
    let clock = TestClock()

    func verifier(_ factory: TokenFactory, clockSkew: TimeInterval = 60) throws -> IDTokenVerifier {
        try IDTokenVerifier(projectID: "demo-fixture", keys: [factory.kid: factory.publicKey], clockSkew: clockSkew, clock: clock.function)
    }

    func claims(_ changes: [String: Any] = [:]) -> [String: Any] {
        TokenFactory.claims(now: clock.now).merging(changes) { $1 }
    }

    @Test("A token signed by a known key with correct claims verifies")
    func acceptsValidToken() async throws {
        let factory = try TokenFactory()
        let verified = try await verifier(factory).verify(factory.token(claims()))
        #expect(verified.subject == "user-1")
        #expect(verified.audience == "demo-fixture")
        #expect(verified.email == "ada@example.com")
        #expect(verified.emailVerified)
        #expect(verified.signInProvider == "password")
        #expect(verified["admin"] == true)
    }

    @Test("Each of Firebase's claim rules is enforced")
    func enforcesClaims() async throws {
        let factory = try TokenFactory()
        let verifier = try verifier(factory)
        let now = clock.now.timeIntervalSince1970
        let cases: [([String: Any], TokenError)] = [
            (["aud": "other-project"], .wrongAudience("other-project")),
            (["iss": "https://securetoken.google.com/other-project"], .wrongIssuer("https://securetoken.google.com/other-project")),
            (["iss": "https://accounts.google.com"], .wrongIssuer("https://accounts.google.com")),
            (["sub": ""], .emptySubject),
            (["sub": String(repeating: "u", count: 129)], .emptySubject),
            (["exp": now - 61], .expired(Date(timeIntervalSince1970: now - 61))),
            (["iat": now + 120], .notYetValid),
            (["auth_time": now + 120], .notYetValid),
        ]
        for (change, expected) in cases {
            let error = await #expect(throws: TokenError.self) { try await verifier.verify(factory.token(claims(change))) }
            #expect(error == expected, "\(change)")
        }
    }

    @Test("Clock skew is allowed up to the configured amount")
    func allowsClockSkew() async throws {
        let factory = try TokenFactory()
        let now = clock.now.timeIntervalSince1970
        _ = try await verifier(factory).verify(factory.token(claims(["exp": now - 30, "iat": now + 30])))
        await #expect(throws: TokenError.self) { try await verifier(factory, clockSkew: 0).verify(factory.token(claims(["exp": now - 1]))) }
    }

    @Test("A NaN, infinite or huge clock skew cannot disable the expiry check", arguments: [Double.nan, .infinity, 1e300, -5])
    func boundsClockSkew(_ skew: Double) async throws {
        let factory = try TokenFactory()
        let expiredAnHourAgo = claims(["exp": clock.now.timeIntervalSince1970 - 3_600])
        await #expect(throws: TokenError.self) { try await verifier(factory, clockSkew: skew).verify(factory.token(expiredAnHourAgo)) }
    }

    @Test("Claims that are not dates in range are malformed, not trapped on", arguments: [
        "1e300", "-1", "\"1800000000\"", "null", "true", "253402300800",
    ])
    func rejectsBadDates(_ exp: String) async throws {
        let factory = try TokenFactory()
        var json = String(decoding: try JSONSerialization.data(withJSONObject: claims(), options: [.sortedKeys]), as: UTF8.self)
        let current = Int(clock.now.timeIntervalSince1970 + 3_600)
        json = json.replacingOccurrences(of: "\"exp\":\(current)", with: "\"exp\":\(exp)")
        let header = Fixtures.base64URL(Data(#"{"alg":"RS256","kid":"test-key-1"}"#.utf8))
        let input = "\(header).\(Fixtures.base64URL(Data(json.utf8)))"
        let token = "\(input).\(Fixtures.base64URL(try factory.sign(Data(input.utf8))))"
        let error = await #expect(throws: TokenError.self) { try await verifier(factory).verify(token) }
        guard case .malformed? = error else { Issue.record("expected malformed, got \(String(describing: error))"); return }
    }

    @Test("Signatures are checked: tampering, another key, alg none and HS256 all fail")
    func checksSignatures() async throws {
        let factory = try TokenFactory()
        let verifier = try verifier(factory)
        let good = try factory.token(claims())
        let parts = good.split(separator: ".").map(String.init)

        let tamperedPayload = Fixtures.base64URL(try JSONSerialization.data(withJSONObject: claims(["sub": "attacker"])))
        await #expect(throws: TokenError.invalidSignature) { try await verifier.verify("\(parts[0]).\(tamperedPayload).\(parts[2])") }

        let other = try TokenFactory(kid: "test-key-1")
        await #expect(throws: TokenError.invalidSignature) { try await verifier.verify(other.token(claims())) }

        let unsigned = Fixtures.unsignedToken(claims())
        await #expect(throws: TokenError.unsupportedAlgorithm("none")) { try await verifier.verify(unsigned) }

        let hs256 = try factory.token(claims(), header: ["alg": "HS256", "kid": factory.kid])
        await #expect(throws: TokenError.unsupportedAlgorithm("HS256")) { try await verifier.verify(hs256) }

        let unknownKid = try factory.token(claims(), header: ["alg": "RS256", "kid": "rotated-away"])
        await #expect(throws: TokenError.unknownKey("rotated-away")) { try await verifier.verify(unknownKid) }
    }

    @Test("Malformed tokens are rejected before any key is used", arguments: [
        "", "a.b", "a.b.c.d", "!!!.e30.", "e30.e30", "e30.e30.e30.", "e30=.e30.", "eyJhbGciOiJSUzI1NiJ9", "W10.e30.",
        "e30.e30.", String(repeating: "a", count: 16_385),
    ])
    func rejectsMalformedTokens(_ token: String) async throws {
        let factory = try TokenFactory()
        let error = await #expect(throws: TokenError.self) { try await verifier(factory).verify(token) }
        guard case .malformed? = error else { Issue.record("expected malformed, got \(String(describing: error))"); return }
    }

    @Test("The emulator verifier accepts unsigned tokens only, and still checks claims")
    func emulatorVerifier() async throws {
        let verifier = try IDTokenVerifier.emulator(projectID: "demo-fixture", clock: clock.function)
        #expect(try await verifier.verify(Fixtures.unsignedToken(claims())).subject == "user-1")
        await #expect(throws: TokenError.self) { try await verifier.verify(Fixtures.unsignedToken(claims(["aud": "prod-project"]))) }
        let signed = try TokenFactory().token(claims())
        await #expect(throws: TokenError.unsupportedAlgorithm("RS256")) { try await verifier.verify(signed) }
    }

    @Test("Keys under 2048 bits and malformed key sets are refused")
    func refusesWeakKeys() throws {
        let weak = try TokenFactory(bits: 1_024)
        #expect(throws: TokenError.self) { try RSAPublicKey(modulus: weak.jwk["n"]!, exponent: weak.jwk["e"]!) }
        #expect(throws: TokenError.self) { try KeySet.parse(Data("{}".utf8)) }
        #expect(throws: TokenError.self) { try KeySet.parse(Data(#"{"keys":[]}"#.utf8)) }
        let many = (0..<33).map { #"{"kty":"RSA","kid":"\#($0)","n":"AQAB","e":"AQAB"}"# }.joined(separator: ",")
        #expect(throws: TokenError.self) { try KeySet.parse(Data(#"{"keys":[\#(many)]}"#.utf8)) }
    }

    @Test("Cache-Control max-age is read with bounds", arguments: [
        (nil, 3_600.0), ("public, max-age=24754, must-revalidate", 24_754), ("max-age=0", 0), ("MAX-AGE = 100", 100),
        ("max-age=999999999", 86_400), ("max-age=99999999999999999999", 3_600), ("max-age=-5", 3_600),
        ("max-age=1e3", 3_600), ("no-store", 3_600),
    ] as [(String?, Double)])
    func readsMaxAge(_ header: String?, _ expected: Double) {
        #expect(KeySet.maxAge(cacheControl: header) == expected)
    }
}

@Suite("Fetching Google's keys")
struct KeyFetchTests {
    let clock = TestClock()

    func keySetResponse(_ factories: [TokenFactory], maxAge: Int = 3_600) throws -> HTTPResponse {
        let body = try JSONSerialization.data(withJSONObject: ["keys": factories.map(\.jwk)])
        return HTTPResponse(statusCode: 200, headers: ["Cache-Control": "public, max-age=\(maxAge)"], body: body)
    }

    @Test("Keys are fetched once, shared by concurrent checks and kept for max-age")
    func cachesKeys() async throws {
        let factory = try TokenFactory()
        let response = try keySetResponse([factory])
        let transport = MockTransport { request, _ in
            #expect(request.url == IDTokenVerifier.googleKeysURL)
            try await Task.sleep(for: .milliseconds(20))
            return response
        }
        let verifier = try IDTokenVerifier(projectID: "demo-fixture", transport: transport, clock: clock.function)
        let token = try factory.token(TokenFactory.claims(now: clock.now))
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<10 { group.addTask { _ = try await verifier.verify(token) } }
            try await group.waitForAll()
        }
        #expect(transport.requests.count == 1)

        clock.advance(by: 3_601)
        _ = try await verifier.verify(factory.token(TokenFactory.claims(now: clock.now)))
        #expect(transport.requests.count == 2)
    }

    @Test("Unknown key IDs refetch at most once a minute")
    func throttlesUnknownKeys() async throws {
        let factory = try TokenFactory()
        let response = try keySetResponse([factory])
        let transport = MockTransport { _, _ in response }
        let verifier = try IDTokenVerifier(projectID: "demo-fixture", transport: transport, clock: clock.function)
        _ = try await verifier.verify(factory.token(TokenFactory.claims(now: clock.now)))

        for index in 0..<50 {
            let forged = try factory.token(TokenFactory.claims(now: clock.now), header: ["alg": "RS256", "kid": "forged-\(index)"])
            await #expect(throws: TokenError.unknownKey("forged-\(index)")) { try await verifier.verify(forged) }
        }
        #expect(transport.requests.count == 1)

        clock.advance(by: 61)
        let forged = try factory.token(TokenFactory.claims(now: clock.now), header: ["alg": "RS256", "kid": "forged-late"])
        await #expect(throws: TokenError.unknownKey("forged-late")) { try await verifier.verify(forged) }
        #expect(transport.requests.count == 2)
    }

    @Test("Cached keys keep working while Google is unreachable")
    func survivesFetchFailure() async throws {
        let factory = try TokenFactory()
        let response = try keySetResponse([factory], maxAge: 60)
        let transport = MockTransport { _, number in
            guard number == 0 else { throw URLError(.cannotConnectToHost) }
            return response
        }
        let verifier = try IDTokenVerifier(projectID: "demo-fixture", transport: transport, clock: clock.function)
        _ = try await verifier.verify(factory.token(TokenFactory.claims(now: clock.now)))
        clock.advance(by: 120)
        _ = try await verifier.verify(factory.token(TokenFactory.claims(now: clock.now)))
        #expect(transport.requests.count == 2)
    }

    @Test("A failed first fetch is reported")
    func reportsFetchFailure() async throws {
        let transport = MockTransport { _, _ in HTTPResponse(statusCode: 500) }
        let verifier = try IDTokenVerifier(projectID: "demo-fixture", transport: transport, clock: clock.function)
        let token = try TokenFactory().token(TokenFactory.claims(now: clock.now))
        await #expect(throws: TokenError.keysUnavailable("HTTP 500")) { try await verifier.verify(token) }
    }
}
