import Foundation
import Testing
@testable import iOSFirebaseTools

/// The text forms of requests and responses, checked against the redaction rules: URLs
/// (user info, fragment, query, path IDs, hosts), headers and bodies.
@Suite("Redacted requests and responses")
struct RedactionHTTPTests {
    func url(_ text: String, _ policy: RedactionPolicy = .default) -> String {
        Redaction.url(URL(string: text)!, policy: policy)
    }

    @Test("User info and the fragment are always dropped")
    func userInfoAndFragment() {
        let text = url("https://ada:hunter2@example.com/notes#access_token=abc", RedactionPolicy(allowedQueryParameters: ["access_token"]))
        #expect(text == "https://example.com/notes")
    }

    @Test("Query values are hidden unless allowlisted, and secret names stay hidden when listed")
    func queryValues() {
        #expect(url("https://example.com/a?key=AIzaSyA&pageSize=10") == "https://example.com/a?key=<redacted>&pageSize=<redacted>")
        let policy = RedactionPolicy(allowedQueryParameters: ["page_size", "key"])
        #expect(url("https://example.com/a?key=AIzaSyA&pageSize=10", policy) == "https://example.com/a?key=<redacted>&pageSize=10")
        #expect(url("https://example.com/a?flag") == "https://example.com/a?flag")
    }

    @Test("Encoded, non-ASCII and look-alike query names are hidden with their values", arguments: [
        "%6Bey", "p%D0%B0ssword", "%C5%9Fifre", "pass%E2%80%8Dword", "%EF%BD%8Bey", "a%0Ab",
    ])
    func obfuscatedQueryNames(_ name: String) {
        let text = url("https://example.com/a?\(name)=s3cr3t-value", RedactionPolicy(allowedQueryParameters: ["key", "password"]))
        #expect(!text.contains("s3cr3t"), "\(text)")
    }

    @Test("ID-like path segments become :id; names and short IDs stay", arguments: [
        ("/v1/projects/demo-lab/databases/(default)/documents/notes/K3vXq9TzPlm2RwYb8NaC",
         "/v1/projects/demo-lab/databases/(default)/documents/notes/:id"),
        ("/users/6kkpCpjp8ZoLQh5pxcKdIGVzJWfr/notes/abc", "/users/:id/notes/abc"),
        ("/orders/123456/items/42", "/orders/:id/items/42"),
        ("/u/0F8E2B76-3A1C-4D5E-9F00-112233445566", "/u/:id"),
        ("/people/ada%40example.com/x", "/people/:id/x"),
        ("/v1/token/abc/def", "/v1/token/:id/def"),
        ("/a/%C5%9Fifre/hunter2/b", "/a/:id/:id/b"),
        ("/a/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef", "/a/:id"),
        ("/v1/accounts:signInWithPassword", "/v1/accounts:signInWithPassword"),
    ])
    func pathSegments(_ path: String, _ expected: String) {
        #expect(url("https://example.com\(path)") == "https://example.com\(expected)")
    }

    @Test("Dot segments, matrix parameters, double encoding and long paths keep scheme and host only", arguments: [
        "/a/../secret", "/a/./b", "/a/%2E%2E/b", "/a/%2e/b", "/a;jsessionid=1/b", "/a%3Bx/b", "/a/%2541/b",
        "/" + Array(repeating: "s", count: 40).joined(separator: "/"),
    ])
    func originOnly(_ path: String) {
        #expect(url("https://example.com:8443\(path)") == "https://example.com:8443")
    }

    @Test("Hosts: a secret name keeps nothing after it; a host that is not LDH is hidden")
    func hosts() {
        #expect(url("myapp://pin/4831") == "myapp://pin")
        #expect(url("http://127.0.0.1:8080/v1/x") == "http://127.0.0.1:8080/v1/x")
        #expect(url("http://[::1]:9099/x") == "http://[::1]:9099/x")
        #expect(url("https://h%C3%A9.example/x") == "https://<redacted>")
        #expect(url("mailto:ada@example.com") == "mailto:<redacted>")
        let long = "https://example.com/" + String(repeating: "a", count: 9_000)
        #expect(url(long) == Redaction.unparsedURL)
    }

    @Test("Headers: values only for the allowlist; secret and non-ASCII names always hidden")
    func headers() {
        let headers = [
            "Authorization": "Bearer x", "Cookie": "sid=1", "X-Api-Key": "k", "X-Goog-Session-Token": "t",
            "X-Custom": "v", "Content-Type": "application/json; charset=utf-8", "Accept": "eyJhbGciOiJSUzI1NiJ9.e30.c2ln",
            "X-Şifre": "hunter2",
        ]
        let text = Redaction.headers(headers, policy: .default)
        #expect(text == "[<redacted>: <redacted>, accept: <redacted>, authorization: <redacted>, content-type: application/json; charset=utf-8, "
            + "cookie: <redacted>, x-api-key: <redacted>, x-custom: <redacted>, x-goog-session-token: <redacted>]")
        let custom = RedactionPolicy(allowedHeaders: ["X-Request-ID", "Authorization"])
        #expect(Redaction.headers(["X-Request-Id": "r-1", "Authorization": "Bearer x"], policy: custom)
            == "[authorization: <redacted>, x-request-id: r-1]")
    }

    @Test("Bodies are never shown; the content type is reduced to a clean media type", arguments: [
        ("application/json; charset=utf-8", "application/json"),
        ("multipart/form-data; boundary=secret-boundary", "multipart/form-data"),
        ("text/plain\u{2028}password=x", "unknown content type"),
        ("application/json/../x", "unknown content type"),
    ])
    func bodies(_ contentType: String, _ shown: String) {
        let body = Data(#"{"password":"hunter2"}"#.utf8)
        #expect(Redaction.body(body, headers: ["Content-Type": contentType]) == "[body omitted: \(body.count) bytes, \(shown)]")
        #expect(Redaction.body(Data(), headers: [:]) == "none")
    }

    @Test("Usefulness: a Firestore request stays readable")
    func usefulness() {
        let request = HTTPRequest(
            method: "GET",
            url: URL(string: "https://firestore.googleapis.com/v1/projects/demo-lab/databases/(default)/documents/notes?pageSize=100")!,
            headers: ["Content-Type": "application/json", "Authorization": "Bearer t"])
        let policy = RedactionPolicy(allowedQueryParameters: ["pageSize"])
        #expect(request.redactedDescription(policy) == "HTTPRequest(GET https://firestore.googleapis.com/v1/projects/demo-lab/databases/"
            + "(default)/documents/notes?pageSize=100, headers: [authorization: <redacted>, content-type: application/json], body: none)")
        #expect(HTTPRequest(method: "G\u{0}ET", url: URL(string: "https://a.example")!).description.hasPrefix("HTTPRequest(<redacted> "))
    }

    @Test("Property: obfuscated secret names never let their value through")
    func obfuscationProperty() {
        var generator = SystemRandomNumberGenerator()
        let names = ["password", "token", "api_key", "authorization", "refresh_token", "secret", "session", "pin"]
        let variants: [(String) -> String] = [
            { $0.uppercased() }, { $0.replacingOccurrences(of: "_", with: "-") }, { $0.replacingOccurrences(of: "_", with: ".") },
            { String($0.map { Character(UnicodeScalar(($0.unicodeScalars.first!.value) + 0xFEE0)!) }) },
            { $0.replacingOccurrences(of: "a", with: "\u{430}").replacingOccurrences(of: "o", with: "\u{43E}") },
            { String($0.prefix(2)) + "\u{200D}" + String($0.dropFirst(2)) },
            { String($0.prefix(1)) + "\u{301}" + String($0.dropFirst()) },
            { $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics.subtracting(CharacterSet(charactersIn: "aeiou")))! },
        ]
        for name in names {
            for variant in variants {
                // Lowercase letters only, so no detector hides the value: only the name rule can.
                let secret = String((0..<12).map { _ in "abcdefghijklmnopqrstuvwxyz".randomElement(using: &generator)! })
                let obfuscated = variant(name)
                let encodedName = obfuscated.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+")))!
                let request = HTTPRequest(method: "POST", url: URL(string: "https://example.com/p?\(encodedName)=\(secret)")!,
                                          headers: [obfuscated: secret], body: Data("\(obfuscated)=\(secret)".utf8))
                let policy = RedactionPolicy(allowedHeaders: [obfuscated], allowedQueryParameters: [obfuscated])
                let text = request.redactedDescription(policy)
                #expect(!text.contains(secret), "\(obfuscated): \(text)")
            }
        }
    }
}
