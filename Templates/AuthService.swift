// MARK: - Firebase Auth Service Template
// Complete authentication service with all auth methods

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

/// Complete Firebase Authentication Service
@MainActor
public final class AuthService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var user: User?
    @Published public private(set) var isAuthenticated = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: AuthError?
    
    // MARK: - Private Properties
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    // MARK: - Singleton
    
    public static let shared = AuthService()
    
    // MARK: - Initialization
    
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    // MARK: - Email/Password Authentication
    
    /// Sign in with email and password
    public func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
        } catch {
            self.error = .signInFailed(error)
            throw error
        }
    }
    
    /// Create new account with email and password
    public func signUp(email: String, password: String, displayName: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            if let displayName = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            user = result.user
            isAuthenticated = true
        } catch {
            self.error = .signUpFailed(error)
            throw error
        }
    }
    
    /// Send password reset email
    public func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            self.error = .passwordResetFailed(error)
            throw error
        }
    }
    
    /// Update password for current user
    public func updatePassword(newPassword: String) async throws {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            self.error = .updatePasswordFailed(error)
            throw error
        }
    }
    
    // MARK: - Apple Sign In
    
    /// Prepare Apple Sign In request
    public func prepareAppleSignIn() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return request
    }
    
    /// Complete Apple Sign In with authorization
    public func signInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.appleSignInFailed(nil)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            let result = try await Auth.auth().signIn(with: credential)
            user = result.user
            isAuthenticated = true
        } catch {
            self.error = .appleSignInFailed(error)
            throw error
        }
    }
    
    // MARK: - Anonymous Authentication
    
    /// Sign in anonymously
    public func signInAnonymously() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
            isAuthenticated = true
        } catch {
            self.error = .anonymousSignInFailed(error)
            throw error
        }
    }
    
    /// Convert anonymous account to permanent
    public func linkEmail(email: String, password: String) async throws {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            let result = try await user.link(with: credential)
            self.user = result.user
        } catch {
            self.error = .linkAccountFailed(error)
            throw error
        }
    }
    
    // MARK: - Sign Out
    
    /// Sign out current user
    public func signOut() throws {
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
        } catch {
            self.error = .signOutFailed(error)
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    /// Update user profile
    public func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let changeRequest = user.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        
        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }
        
        try await changeRequest.commitChanges()
        try await user.reload()
        self.user = Auth.auth().currentUser
    }
    
    /// Delete user account
    public func deleteAccount() async throws {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await user.delete()
            self.user = nil
            isAuthenticated = false
        } catch {
            self.error = .deleteAccountFailed(error)
            throw error
        }
    }
    
    // MARK: - Re-authentication
    
    /// Re-authenticate user (required for sensitive operations)
    public func reauthenticate(email: String, password: String) async throws {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    // MARK: - Token Management
    
    /// Get current ID token
    public func getIDToken(forceRefresh: Bool = false) async throws -> String {
        guard let user = user else {
            throw AuthError.noUser
        }
        
        return try await user.getIDToken(forcingRefresh: forceRefresh)
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        return String(randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        })
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Auth Error

public enum AuthError: LocalizedError {
    case noUser
    case signInFailed(Error)
    case signUpFailed(Error)
    case signOutFailed(Error)
    case passwordResetFailed(Error)
    case updatePasswordFailed(Error)
    case appleSignInFailed(Error?)
    case anonymousSignInFailed(Error)
    case linkAccountFailed(Error)
    case deleteAccountFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noUser:
            return "No user is currently signed in"
        case .signInFailed(let error):
            return "Sign in failed: \(error.localizedDescription)"
        case .signUpFailed(let error):
            return "Sign up failed: \(error.localizedDescription)"
        case .signOutFailed(let error):
            return "Sign out failed: \(error.localizedDescription)"
        case .passwordResetFailed(let error):
            return "Password reset failed: \(error.localizedDescription)"
        case .updatePasswordFailed(let error):
            return "Update password failed: \(error.localizedDescription)"
        case .appleSignInFailed(let error):
            return "Apple sign in failed: \(error?.localizedDescription ?? "Unknown error")"
        case .anonymousSignInFailed(let error):
            return "Anonymous sign in failed: \(error.localizedDescription)"
        case .linkAccountFailed(let error):
            return "Link account failed: \(error.localizedDescription)"
        case .deleteAccountFailed(let error):
            return "Delete account failed: \(error.localizedDescription)"
        }
    }
}
