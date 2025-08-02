import Foundation
import FirebaseAuth
import LocalAuthentication

// MARK: - Firebase Auth Manager
public class FirebaseAuthManager: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = FirebaseAuthManager()
    
    // MARK: - Published Properties
    @Published public var currentUser: User?
    @Published public var isAuthenticated = false
    @Published public var authState: AuthState = .unknown
    
    // MARK: - Private Properties
    private let auth = Auth.auth()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        removeAuthStateListener()
    }
    
    // MARK: - Public Methods
    
    /// Initialize Firebase Auth Manager
    public func initialize() {
        setupAuthStateListener()
    }
    
    /// Sign in with email and password
    public func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            throw FirebaseAuthError.signInFailed(error)
        }
    }
    
    /// Sign up with email and password
    public func signUp(email: String, password: String, displayName: String? = nil) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            if let displayName = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            return result.user
        } catch {
            throw FirebaseAuthError.signUpFailed(error)
        }
    }
    
    /// Sign out current user
    public func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw FirebaseAuthError.signOutFailed(error)
        }
    }
    
    /// Reset password
    public func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw FirebaseAuthError.passwordResetFailed(error)
        }
    }
    
    /// Update user profile
    public func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
        guard let user = auth.currentUser else {
            throw FirebaseAuthError.noCurrentUser
        }
        
        do {
            let changeRequest = user.createProfileChangeRequest()
            if let displayName = displayName {
                changeRequest.displayName = displayName
            }
            if let photoURL = photoURL {
                changeRequest.photoURL = photoURL
            }
            try await changeRequest.commitChanges()
        } catch {
            throw FirebaseAuthError.profileUpdateFailed(error)
        }
    }
    
    /// Delete current user account
    public func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw FirebaseAuthError.noCurrentUser
        }
        
        do {
            try await user.delete()
        } catch {
            throw FirebaseAuthError.accountDeletionFailed(error)
        }
    }
    
    /// Get current user
    public func getCurrentUser() -> User? {
        return auth.currentUser
    }
    
    /// Check if user is signed in
    public func isUserSignedIn() -> Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Private Methods
    
    private func setupAuthStateListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                self?.authState = user != nil ? .signedIn : .signedOut
            }
        }
    }
    
    private func removeAuthStateListener() {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
}

// MARK: - Social Auth Provider
public class SocialAuthProvider {
    
    // MARK: - Singleton
    public static let shared = SocialAuthProvider()
    
    // MARK: - Private Properties
    private let auth = Auth.auth()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Sign in with Apple
    public func signInWithApple() async throws -> User {
        // Implementation for Apple Sign In
        // This would require Apple Sign In SDK integration
        throw FirebaseAuthError.socialSignInFailed(NSError(domain: "Not implemented", code: -1))
    }
    
    /// Sign in with Google
    public func signInWithGoogle() async throws -> User {
        // Implementation for Google Sign In
        // This would require Google Sign In SDK integration
        throw FirebaseAuthError.socialSignInFailed(NSError(domain: "Not implemented", code: -1))
    }
    
    /// Sign in with Facebook
    public func signInWithFacebook() async throws -> User {
        // Implementation for Facebook Sign In
        // This would require Facebook Sign In SDK integration
        throw FirebaseAuthError.socialSignInFailed(NSError(domain: "Not implemented", code: -1))
    }
}

// MARK: - Biometric Auth
public class BiometricAuth {
    
    // MARK: - Singleton
    public static let shared = BiometricAuth()
    
    // MARK: - Private Properties
    private let context = LAContext()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Check if biometric authentication is available
    public func isBiometricAvailable() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Get biometric type
    public func getBiometricType() -> BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    /// Authenticate with biometrics
    public func authenticate(reason: String = "Authenticate to continue") async throws {
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: FirebaseAuthError.biometricAuthFailed(error))
                }
            }
        }
    }
}

// MARK: - Auth State Listener
public class AuthStateListener {
    
    // MARK: - Singleton
    public static let shared = AuthStateListener()
    
    // MARK: - Private Properties
    private let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Start listening to auth state changes
    public func startListening(onStateChange: @escaping (AuthState) -> Void) {
        listener = auth.addStateDidChangeListener { _, user in
            let state: AuthState = user != nil ? .signedIn : .signedOut
            DispatchQueue.main.async {
                onStateChange(state)
            }
        }
    }
    
    /// Stop listening to auth state changes
    public func stopListening() {
        if let listener = listener {
            auth.removeStateDidChangeListener(listener)
            self.listener = nil
        }
    }
}

// MARK: - Supporting Types

/// Authentication state enum
public enum AuthState {
    case unknown
    case signedIn
    case signedOut
}

/// Biometric type enum
public enum BiometricType {
    case none
    case touchID
    case faceID
}

/// Firebase Auth Error enum
public enum FirebaseAuthError: LocalizedError {
    case signInFailed(Error)
    case signUpFailed(Error)
    case signOutFailed(Error)
    case passwordResetFailed(Error)
    case profileUpdateFailed(Error)
    case accountDeletionFailed(Error)
    case socialSignInFailed(Error)
    case biometricAuthFailed(Error?)
    case noCurrentUser
    
    public var errorDescription: String? {
        switch self {
        case .signInFailed(let error):
            return "Sign in failed: \(error.localizedDescription)"
        case .signUpFailed(let error):
            return "Sign up failed: \(error.localizedDescription)"
        case .signOutFailed(let error):
            return "Sign out failed: \(error.localizedDescription)"
        case .passwordResetFailed(let error):
            return "Password reset failed: \(error.localizedDescription)"
        case .profileUpdateFailed(let error):
            return "Profile update failed: \(error.localizedDescription)"
        case .accountDeletionFailed(let error):
            return "Account deletion failed: \(error.localizedDescription)"
        case .socialSignInFailed(let error):
            return "Social sign in failed: \(error.localizedDescription)"
        case .biometricAuthFailed(let error):
            return "Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")"
        case .noCurrentUser:
            return "No current user"
        }
    }
} 