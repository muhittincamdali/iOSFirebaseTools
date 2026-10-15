import Foundation

/// Builds the Identity Toolkit and Secure Token requests and reads their responses.
struct AuthEndpoints: Sendable {
    let project: FirebaseProject

    enum Method: String {
        case signUp = "accounts:signUp"
        case signInWithPassword = "accounts:signInWithPassword"
        case sendOobCode = "accounts:sendOobCode"
        case delete = "accounts:delete"
        case update = "accounts:update"
    }

    func identityToolkit(_ method: Method, body: some Encodable, locale: String? = nil) throws -> HTTPRequest {
        let base = project.authEmulator.map { "\($0.baseURL)/identitytoolkit.googleapis.com/v1/" }
            ?? "https://identitytoolkit.googleapis.com/v1/"
        var request = HTTPRequest(method: "POST", url: try url(base + method.rawValue), headers: headers("application/json"))
        request.body = try JSONBody.encode(body)
        if let locale { request.headers["X-Firebase-Locale"] = locale }
        return request
    }

    func refresh(refreshToken: Secret) throws -> HTTPRequest {
        let base = project.authEmulator.map { "\($0.baseURL)/securetoken.googleapis.com/v1/token" }
            ?? "https://securetoken.googleapis.com/v1/token"
        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken.revealed)
        ]
        // URLComponents leaves "+" alone, which a form body would read as a space.
        let body = (form.percentEncodedQuery ?? "").replacingOccurrences(of: "+", with: "%2B")
        var request = HTTPRequest(method: "POST", url: try url(base), headers: headers("application/x-www-form-urlencoded"))
        request.body = Data(body.utf8)
        return request
    }

    private func url(_ string: String) throws -> URL {
        guard var components = URLComponents(string: string) else {
            throw ValidationError("Authentication URL", string)
        }
        components.queryItems = [URLQueryItem(name: "key", value: project.apiKey)]
        guard let url = components.url else { throw ValidationError("Authentication URL", string) }
        return url
    }

    private func headers(_ contentType: String) -> [String: String] {
        var headers = ["Content-Type": contentType]
        if let bundleID = project.bundleID { headers["X-Ios-Bundle-Identifier"] = bundleID }
        return headers
    }
}

/// Request and response bodies of the Authentication REST API.
enum AuthBodies {
    struct Credentials: Encodable {
        var email: String?
        var password: String?
        let returnSecureToken = true
    }

    struct PasswordReset: Encodable {
        let requestType = "PASSWORD_RESET"
        let email: String
    }

    struct IDTokenOnly: Encodable {
        let idToken: String
    }

    struct SignInResponse: Decodable {
        let idToken: String
        let refreshToken: String
        let expiresIn: String
        let localId: String
        let email: String?
    }

    struct RefreshResponse: Decodable {
        let id_token: String
        let refresh_token: String
        let expires_in: String
        let user_id: String
    }

    /// `expiresIn` is a decimal string of seconds. It is read as digits only, so a value such as
    /// "1e400", "-5" or "NaN" is an error instead of a date in the past or a crash.
    static func lifetime(_ expiresIn: String, statusCode: Int) throws -> TimeInterval {
        guard (1...6).contains(expiresIn.count), expiresIn.allSatisfy(\.isASCIIDigit),
              let seconds = Int(expiresIn), (1...86_400).contains(seconds) else {
            throw MalformedResponseError(statusCode: statusCode, reason: "expiresIn \"\(expiresIn.prefix(20))\" is not 1–86400 seconds")
        }
        return TimeInterval(seconds)
    }
}
