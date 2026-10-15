import CryptoKit
import Foundation

/// A sign-in from another identity provider, such as Sign in with Apple or Google, to exchange
/// for a Firebase session with ``FirebaseAuthClient/signIn(with:)``.
///
/// The provider must be enabled under **Authentication › Sign-in method** in the Firebase
/// console. The tokens are ``Secret`` values and never print.
public struct IdentityProviderCredential: Sendable, Hashable {
    /// The provider ID, such as `apple.com` or `google.com`.
    public let providerID: String
    let idToken: Secret?
    let accessToken: Secret?
    let rawNonce: Secret?

    /// A credential from Sign in with Apple.
    ///
    /// - Parameters:
    ///   - idToken: `ASAuthorizationAppleIDCredential.identityToken`, decoded as UTF-8.
    ///   - rawNonce: The ``AppleSignInNonce/raw`` value whose hash you put in the Apple ID request.
    public static func apple(idToken: String, rawNonce: String) -> IdentityProviderCredential {
        IdentityProviderCredential(providerID: "apple.com", idToken: Secret(idToken), accessToken: nil, rawNonce: Secret(rawNonce))
    }

    /// A credential from Google Sign-In: its ID token, and the access token if you have one.
    public static func google(idToken: String, accessToken: String? = nil) -> IdentityProviderCredential {
        IdentityProviderCredential(providerID: "google.com", idToken: Secret(idToken), accessToken: accessToken.map(Secret.init), rawNonce: nil)
    }

    /// Any OpenID Connect provider Firebase supports, with an ID token, an access token or both.
    public init(providerID: String, idToken: String?, accessToken: String? = nil) throws {
        guard !providerID.isEmpty, providerID.utf8Count <= 128,
              providerID.allSatisfy({ $0.isASCIILetterOrDigit || $0 == "." || $0 == "-" || $0 == "_" }) else {
            throw ValidationError("providerID", "use an ID such as apple.com or oidc.example")
        }
        guard idToken != nil || accessToken != nil else {
            throw ValidationError("credential", "pass an ID token, an access token or both")
        }
        self.init(providerID: providerID, idToken: idToken.map(Secret.init), accessToken: accessToken.map(Secret.init), rawNonce: nil)
    }

    private init(providerID: String, idToken: Secret?, accessToken: Secret?, rawNonce: Secret?) {
        self.providerID = providerID
        self.idToken = idToken
        self.accessToken = accessToken
        self.rawNonce = rawNonce
    }

    /// The form-encoded `postBody` of `accounts:signInWithIdp`.
    var postBody: String {
        var form = URLComponents()
        var items = [URLQueryItem(name: "providerId", value: providerID)]
        if let idToken { items.append(URLQueryItem(name: "id_token", value: idToken.revealed)) }
        if let accessToken { items.append(URLQueryItem(name: "access_token", value: accessToken.revealed)) }
        if let rawNonce { items.append(URLQueryItem(name: "nonce", value: rawNonce.revealed)) }
        form.queryItems = items
        // URLComponents leaves "+" alone, which a form body would read as a space.
        return (form.percentEncodedQuery ?? "").replacingOccurrences(of: "+", with: "%2B")
    }
}

/// A random nonce for Sign in with Apple: put ``sha256`` in the Apple ID request and pass
/// ``raw`` to ``IdentityProviderCredential/apple(idToken:rawNonce:)``, so Firebase can check that
/// Apple's token was issued for this request.
///
/// ```swift
/// let nonce = AppleSignInNonce()
/// let request = ASAuthorizationAppleIDProvider().createRequest()
/// request.requestedScopes = [.email]
/// request.nonce = nonce.sha256
/// // …after Apple answers:
/// try await auth.signIn(with: .apple(idToken: identityToken, rawNonce: nonce.raw))
/// ```
public struct AppleSignInNonce: Sendable, Hashable {
    /// 32 random characters from the system's secure random generator.
    public let raw: String

    public init() {
        let alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var generator = SystemRandomNumberGenerator()
        raw = String((0..<32).map { _ in alphabet.randomElement(using: &generator)! })
    }

    init(raw: String) {
        self.raw = raw
    }

    /// The SHA-256 of ``raw`` in lowercase hexadecimal, for `ASAuthorizationAppleIDRequest.nonce`.
    public var sha256: String {
        SHA256.hash(data: Data(raw.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

extension FirebaseAuthClient {
    /// Signs in with a credential from another identity provider, creating the Firebase user on
    /// first sign-in.
    ///
    /// Throws ``AuthError`` with code `other("NEED_CONFIRMATION")` when the e-mail already
    /// belongs to a user of another provider and the project allows one account per e-mail.
    @discardableResult
    public func signIn(with credential: IdentityProviderCredential) async throws -> AuthSession {
        let body = SignInWithIdpBody(postBody: credential.postBody)
        let response = try await send(endpoints.identityToolkit(.signInWithIdp, body: body))
        let outcome = try JSONBody.decode(SignInWithIdpOutcome.self, from: response)
        if outcome.needConfirmation == true {
            throw AuthError(code: .other("NEED_CONFIRMATION"),
                            message: "An account with this e-mail exists for another sign-in method", statusCode: response.statusCode)
        }
        if let message = outcome.errorMessage {
            throw AuthError(code: AuthError.Code(serverCode: message), message: String(message.prefix(500)), statusCode: response.statusCode)
        }
        return try await startSession(from: response, anonymous: false)
    }
}

private struct SignInWithIdpBody: Encodable {
    let postBody: String
    // Identity Toolkit requires a URI; it is not opened for ID token sign-ins.
    let requestUri = "http://localhost"
    let returnIdpCredential = true
    let returnSecureToken = true
}

private struct SignInWithIdpOutcome: Decodable {
    let needConfirmation: Bool?
    let errorMessage: String?
}
