import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Detectors")
struct DetectorTests {
    @Test("E-mail addresses with Unicode local parts and domains", arguments: [
        "çağrı.yılmaz@örnek.com.tr", "åse.ødegård@example.no", "łukasz@przykład.pl", "张伟@example.cn", "a+b@x.io",
    ])
    func emails(_ text: String) {
        #expect(Detectors.matches("contact \(text) today"))
    }

    @Test("Cards pass Luhn, IBANs pass mod 97, across Unicode line separators")
    func numbers() {
        #expect(Detectors.matches("4111 1111 1111 1111"))
        #expect(Detectors.matches("4111\u{2028}1111\u{85}1111-1111"))
        #expect(!Detectors.matches("4111 1111 1111 1112"))
        #expect(Detectors.matches("DE89 3704 0044 0532 0130 00"))
        #expect(Detectors.matches("gb82west12345698765432"))
        #expect(!Detectors.matches("GB82 WEST 1234 5698 7654 33"))
        #expect(Detectors.matches(String(repeating: "7", count: 24)))
    }

    @Test("Tokens: JWTs, bearer values and long base64 or hex runs; ordinary words are not")
    func tokens() {
        #expect(Detectors.matches("eyJhbGciOiJSUzI1NiJ9.e30.c2ln"))
        #expect(Detectors.matches("Bearer abc"))
        #expect(Detectors.matches("0123456789abcdef0123456789abcdef"))
        #expect(!Detectors.matches("application/x-www-form-urlencoded"))
        #expect(!Detectors.matches("status=200 method=GET path=/api/items"))
    }
}

@Suite("Redacted errors and values")
struct RedactionTextTests {
    @Test("Server messages stay out of error descriptions, and odd codes are hidden")
    func serverErrors() {
        let auth = AuthError.from(.googleError(400, message: "WEAK_PASSWORD : hunter2 for ada@example.com"))
        #expect(auth.description == "AuthError(weakPassword, HTTP 400)")
        #expect(auth.message.contains("hunter2"))
        let odd = AuthError.from(.googleError(400, message: "token eyJhbGciOi.e30.x leaked"))
        #expect(odd.description == "AuthError(other(<redacted, 29 characters>), HTTP 400)")
        #expect(AuthError.from(.googleError(400, message: "QUOTA_EXCEEDED")).description == "AuthError(other(QUOTA_EXCEEDED), HTTP 400)")
        let firestore = FirestoreError.from(.googleError(403, message: "denied for users/6kkpCpjp8ZoLQh5pxcKdIGVzJWfr", code: "PERMISSION_DENIED"))
        #expect(firestore.description == "FirestoreError(permissionDenied, HTTP 403)")
    }

    @Test("dump, debugPrint, Mirror and localizedDescription show the errors' text forms, not the server's text or the token's values")
    func errorsInDumpAndDebugger() {
        let auth = AuthError.from(.googleError(400, message: "WEAK_PASSWORD : hunter2 for ada@example.com"))
        let odd = AuthError.from(.googleError(400, message: "token eyJhbGciOi.e30.x for ada@example.com"))
        let firestore = FirestoreError.from(.googleError(403, message: "denied for ada@example.com, key AIzaSyA-0123456789abcdefghijklmnopqrstu", code: "hunter2 ada@example.com"))
        let token = TokenError.wrongIssuer("https://evil.example/ada@example.com")
        let values: [Any] = [auth, odd, odd.code, firestore, firestore.code, token, TokenError.unknownKey("eyJhbGciOiJSUzI1NiJ9.e30.c2ln")]
        for value in values {
            var dumped = ""
            dump(value, to: &dumped)
            let children = Mirror(reflecting: value).children.map { "\($0.label ?? ""): \($0.value)" }.joined(separator: ", ")
            // Errors bridged to NSError, as crash reporters and os_log see them.
            let bridged = (value as? any Error).map { error in
                [error.localizedDescription, (error as NSError).debugDescription, "\((error as NSError).userInfo)"]
            } ?? []
            for text in [dumped, String(reflecting: value), children] + bridged {
                for secret in ["hunter2", "ada@example.com", "eyJhbGciOi", "AIzaSy"] {
                    #expect(!text.contains(secret), "\(text)")
                }
            }
        }
        #expect(String(reflecting: auth) == "AuthError(weakPassword, HTTP 400)")
        #expect(String(reflecting: firestore.code) == "other(<redacted, 23 characters>)")
        #expect(String(reflecting: token) == "The token was issued by <redacted, 36 characters>")
    }

    @Test("Unreadable responses name the field, not the value")
    func malformedResponses() throws {
        enum Kind: String, Decodable { case a }
        struct Body: Decodable { let kind: Kind; let count: Int }
        let response = HTTPResponse(statusCode: 200, body: Data(#"{"kind":"hunter2-secret","count":1}"#.utf8))
        let error = try #require(throws: MalformedResponseError.self) { try JSONBody.decode(Body.self, from: response) }
        #expect(!error.description.contains("hunter2"), "\(error)")
        #expect(error.description.contains("at kind"), "\(error)")
        let wrongType = HTTPResponse(statusCode: 200, body: Data(#"{"kind":"a","count":"4111111111111111"}"#.utf8))
        let second = try #require(throws: MalformedResponseError.self) { try JSONBody.decode(Body.self, from: wrongType) }
        #expect(!second.description.contains("4111"), "\(second)")
    }

    @Test("Token errors quote only short printable values from the token")
    func tokenErrors() {
        #expect(TokenError.wrongAudience("other-project").description == #"The token is for project "other-project""#)
        #expect(TokenError.wrongIssuer("evil\nINFO forged log line").description == "The token was issued by <redacted, 25 characters>")
        #expect(TokenError.unknownKey("eyJhbGciOiJSUzI1NiJ9.e30.c2ln").description.contains("<redacted"))
    }

    @Test("Paths in validation errors hide IDs; developer values are quoted or hidden")
    func validationErrors() throws {
        let error = try #require(throws: ValidationError.self) { try DocumentPath("users/6kkpCpjp8ZoLQh5pxcKdIGVzJWfr/notes") }
        #expect(error.description.hasPrefix(#"Invalid document path "users/:id/notes""#), "\(error)")
        let address = try #require(throws: ValidationError.self) { try EmulatorHost("ada:hunter2@127.0.0.1:x") }
        #expect(!address.description.contains("hunter2"), "\(address)")
        #expect(Redaction.label("demo-lab") == #""demo-lab""#)
        #expect(Redaction.label("2026-10-15T08:41:00+24:00") == #""2026-10-15T08:41:00+24:00""#)
        #expect(Redaction.label("[::1]:9099") == #""[::1]:9099""#)
        #expect(Redaction.label("https://securetoken.google.com/demo-lab") == #""https://securetoken.google.com/demo-lab""#)
        for compound in ["resetToken abc", "userPassword hunter2", "apiKey2 abc"] {
            #expect(Redaction.label(compound).hasPrefix("<redacted, "), "\(compound)")
        }
        for hidden in ["a\u{202E}b", "x=hunter2", "pass%3Dword", "a&#61;b", "a\\u0041", "tab\there", "my-token-x", "a\"b", "<b>x</b>"] {
            #expect(Redaction.label(hidden).hasPrefix("<redacted, "), "\(hidden)")
        }
    }

    @Test("Projects and plists print without the API key")
    func projectsHideAPIKey() throws {
        let project = try FirebaseProject(projectID: "demo-lab", apiKey: "AIzaSyD-not-a-real-key-000000000000000", bundleID: nil)
        var dumped = ""
        dump(project, to: &dumped)
        for text in [project.description, String(reflecting: project), dumped] {
            #expect(!text.contains("AIzaSy"), "\(text)")
        }
    }
}

/// The transport from the Logging and Redaction article, compiled here.
struct LoggingTransport: HTTPTransport {
    let base = URLSessionTransport()
    let policy = RedactionPolicy(allowedHeaders: RedactionPolicy.defaultAllowedHeaders.union(["x-request-id"]),
                                 allowedQueryParameters: ["pageSize"])

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        print(request.redactedDescription(policy))
        let response = try await base.send(request)
        print(response.redactedDescription(policy))
        return response
    }
}

@Suite("Logging and Redaction article")
struct RedactionArticleTests {
    @Test("The article's request prints as the article shows")
    func articleExample() {
        let request = HTTPRequest(
            method: "POST",
            url: URL(string: "https://securetoken.googleapis.com/v1/token?key=AIza…")!,
            headers: ["Content-Type": "application/x-www-form-urlencoded", "Authorization": "Bearer eyJ…"],
            body: Data("grant_type=refresh_token&refresh_token=AMf-vB…".utf8)
        )
        #expect(request.description == "HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>, "
            + "headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded], "
            + "body: [body omitted: 48 bytes, application/x-www-form-urlencoded])")
        let listed = LoggingTransport().policy
        #expect(Redaction.headers(["X-Request-ID": "r-1", "Authorization": "Bearer x"], policy: listed)
            == "[authorization: <redacted>, x-request-id: r-1]")
    }
}

@Suite("Redaction limits")
struct RedactionLimitTests {
    /// Runs `body` on a thread with a 512 KiB stack, the size the redaction rules are tested at.
    func onSmallStack(_ body: @escaping @Sendable () -> Void) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let thread = Thread {
                body()
                continuation.resume()
            }
            thread.stackSize = 512 * 1_024
            thread.start()
        }
    }

    @Test("A megabyte of URL, headers, path or labels is handled fast on a 512 KiB stack")
    func megabyteInputs() async {
        let megabyte = String(repeating: "a1/", count: 350_000)
        let headers = Dictionary(uniqueKeysWithValues: (0..<1_000).map { ("x-h\($0)", String(repeating: "v", count: 1_000)) })
        let start = ContinuousClock.now
        await onSmallStack {
            _ = Redaction.url(URL(string: "https://example.com/" + megabyte)!, policy: .default)
            _ = Redaction.headers(headers, policy: .default)
            _ = Redaction.path(megabyte)
            _ = Redaction.label(megabyte)
            _ = Detectors.matches(String(megabyte.prefix(Redaction.maxValueLength)))
            _ = Redaction.body(Data(count: 1_048_576), headers: ["content-type": megabyte])
        }
        let elapsed = ContinuousClock.now - start
        // One second in release; debug builds of the tests get more room.
        #expect(elapsed < .seconds(Self.isDebug ? 10 : 1), "\(elapsed)")
        #expect(Redaction.headers(headers, policy: .default).hasSuffix(", +936 more]"))
    }

    static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}
