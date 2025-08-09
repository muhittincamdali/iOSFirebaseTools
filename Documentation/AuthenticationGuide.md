# Authentication Guide

<!-- TOC START -->
## Table of Contents
- [Authentication Guide](#authentication-guide)
- [🔐 Firebase Authentication Integration Guide](#-firebase-authentication-integration-guide)
- [🚀 Quick Start](#-quick-start)
  - [1. Installation](#1-installation)
  - [2. Basic Setup](#2-basic-setup)
  - [3. First Sign-In](#3-first-sign-in)
- [🔑 Authentication Methods](#-authentication-methods)
  - [Email/Password Authentication](#emailpassword-authentication)
  - [Google Sign-In](#google-sign-in)
  - [Phone Authentication](#phone-authentication)
  - [Anonymous Authentication](#anonymous-authentication)
- [👤 User Management](#-user-management)
  - [User Profile Management](#user-profile-management)
  - [User State Management](#user-state-management)
- [🔐 Multi-Factor Authentication](#-multi-factor-authentication)
  - [Setup MFA](#setup-mfa)
  - [MFA Management](#mfa-management)
- [🚪 Sign Out](#-sign-out)
  - [Sign Out Methods](#sign-out-methods)
- [🔧 Configuration](#-configuration)
  - [Authentication Configuration](#authentication-configuration)
  - [Security Configuration](#security-configuration)
- [🛡️ Security Best Practices](#-security-best-practices)
  - [Password Security](#password-security)
  - [Session Management](#session-management)
  - [Data Protection](#data-protection)
- [🔗 Related Documentation](#-related-documentation)
- [📞 Support](#-support)
<!-- TOC END -->


## 🔐 Firebase Authentication Integration Guide

Complete guide for integrating Firebase Authentication into your iOS application.

---

## 🚀 Quick Start

### 1. Installation

Add Firebase Authentication to your project:

```swift
// Swift Package Manager
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "1.0.0")
]

// Import the module
import iOSFirebaseTools
```

### 2. Basic Setup

```swift
import iOSFirebaseTools

// Initialize authentication manager
let authManager = FirebaseAuthManager.shared

// Configure authentication
let config = FirebaseAuthConfiguration()
config.enableGoogleSignIn = true
config.enableEmailPassword = true
config.enablePhoneAuth = true
config.enableAnonymousAuth = true

authManager.configure(config) { result in
    switch result {
    case .success:
        print("✅ Authentication configured successfully")
    case .failure(let error):
        print("❌ Authentication configuration failed: \(error)")
    }
}
```

### 3. First Sign-In

```swift
// Sign in with email and password
authManager.signInWithEmail(
    email: "user@example.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Sign-in successful")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
    case .failure(let error):
        print("❌ Sign-in failed: \(error)")
    }
}
```

---

## 🔑 Authentication Methods

### Email/Password Authentication

The most common authentication method:

```swift
// Sign in with email
authManager.signInWithEmail(
    email: "user@example.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Email sign-in successful")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
        print("Display name: \(user.displayName)")
    case .failure(let error):
        print("❌ Email sign-in failed: \(error)")
    }
}

// Create account with email
authManager.createUserWithEmail(
    email: "newuser@example.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Account created successfully")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
    case .failure(let error):
        print("❌ Account creation failed: \(error)")
    }
}

// Reset password
authManager.sendPasswordResetEmail(
    email: "user@example.com"
) { result in
    switch result {
    case .success:
        print("✅ Password reset email sent")
    case .failure(let error):
        print("❌ Password reset failed: \(error)")
    }
}
```

### Google Sign-In

Integrate Google Sign-In for seamless authentication:

```swift
// Configure Google Sign-In
authManager.configureGoogleSignIn(
    clientID: "your-google-client-id"
) { result in
    switch result {
    case .success:
        print("✅ Google Sign-In configured")
    case .failure(let error):
        print("❌ Google Sign-In configuration failed: \(error)")
    }
}

// Sign in with Google
authManager.signInWithGoogle { result in
    switch result {
    case .success(let user):
        print("✅ Google sign-in successful")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
        print("Display name: \(user.displayName)")
        print("Photo URL: \(user.photoURL)")
    case .failure(let error):
        print("❌ Google sign-in failed: \(error)")
    }
}

// Sign in with Google and custom parameters
authManager.signInWithGoogle(
    presenting: self,
    additionalScopes: ["profile", "email"]
) { result in
    switch result {
    case .success(let user):
        print("✅ Google sign-in with scopes successful")
    case .failure(let error):
        print("❌ Google sign-in failed: \(error)")
    }
}
```

### Phone Authentication

SMS-based authentication:

```swift
// Send verification code
authManager.signInWithPhone(
    phoneNumber: "+1234567890"
) { result in
    switch result {
    case .success(let verificationID):
        print("✅ Verification code sent")
        print("Verification ID: \(verificationID)")
        // Store verificationID for later use
    case .failure(let error):
        print("❌ Phone verification failed: \(error)")
    }
}

// Verify code and sign in
authManager.verifyPhoneCode(
    verificationID: "stored-verification-id",
    code: "123456"
) { result in
    switch result {
    case .success(let user):
        print("✅ Phone verification successful")
        print("User ID: \(user.uid)")
        print("Phone: \(user.phoneNumber)")
    case .failure(let error):
        print("❌ Phone verification failed: \(error)")
    }
}
```

### Anonymous Authentication

Allow users to use your app without creating an account:

```swift
// Sign in anonymously
authManager.signInAnonymously { result in
    switch result {
    case .success(let user):
        print("✅ Anonymous sign-in successful")
        print("User ID: \(user.uid)")
        print("Is anonymous: \(user.isAnonymous)")
    case .failure(let error):
        print("❌ Anonymous sign-in failed: \(error)")
    }
}

// Link anonymous account with email
authManager.linkAnonymousAccount(
    email: "user@example.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Anonymous account linked")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
    case .failure(let error):
        print("❌ Account linking failed: \(error)")
    }
}
```

---

## 👤 User Management

### User Profile Management

```swift
// Get current user
if let currentUser = authManager.getCurrentUser() {
    print("Current user: \(currentUser.uid)")
    print("Email: \(currentUser.email)")
    print("Display name: \(currentUser.displayName)")
    print("Photo URL: \(currentUser.photoURL)")
    print("Is email verified: \(currentUser.isEmailVerified)")
    print("Is anonymous: \(currentUser.isAnonymous)")
}

// Update user profile
let profileUpdates = UserProfileChangeRequest()
profileUpdates.displayName = "John Doe"
profileUpdates.photoURL = URL(string: "https://example.com/photo.jpg")

authManager.updateProfile(profileUpdates) { result in
    switch result {
    case .success:
        print("✅ Profile updated successfully")
    case .failure(let error):
        print("❌ Profile update failed: \(error)")
    }
}

// Update email
authManager.updateEmail(
    newEmail: "newemail@example.com"
) { result in
    switch result {
    case .success:
        print("✅ Email updated successfully")
    case .failure(let error):
        print("❌ Email update failed: \(error)")
    }
}

// Update password
authManager.updatePassword(
    newPassword: "newpassword123"
) { result in
    switch result {
    case .success:
        print("✅ Password updated successfully")
    case .failure(let error):
        print("❌ Password update failed: \(error)")
    }
}
```

### User State Management

```swift
// Listen for authentication state changes
authManager.addAuthStateListener { user in
    if let user = user {
        print("✅ User signed in: \(user.uid)")
        print("Email: \(user.email)")
    } else {
        print("❌ User signed out")
    }
}

// Remove auth state listener
authManager.removeAuthStateListener()

// Check if user is signed in
if authManager.isUserSignedIn() {
    print("✅ User is signed in")
} else {
    print("❌ User is not signed in")
}

// Get user token
authManager.getUserToken { result in
    switch result {
    case .success(let token):
        print("✅ User token: \(token)")
    case .failure(let error):
        print("❌ Token retrieval failed: \(error)")
    }
}
```

---

## 🔐 Multi-Factor Authentication

### Setup MFA

```swift
// Enable multi-factor authentication
authManager.enableMultiFactorAuthentication { result in
    switch result {
    case .success:
        print("✅ MFA enabled")
    case .failure(let error):
        print("❌ MFA setup failed: \(error)")
    }
}

// Setup phone as second factor
authManager.setupPhoneAsSecondFactor(
    phoneNumber: "+1234567890"
) { result in
    switch result {
    case .success(let verificationID):
        print("✅ Phone MFA setup initiated")
        print("Verification ID: \(verificationID)")
    case .failure(let error):
        print("❌ Phone MFA setup failed: \(error)")
    }
}

// Verify MFA code
authManager.verifyMultiFactorCode(
    verificationID: "stored-verification-id",
    code: "123456"
) { result in
    switch result {
    case .success:
        print("✅ MFA verification successful")
    case .failure(let error):
        print("❌ MFA verification failed: \(error)")
    }
}
```

### MFA Management

```swift
// Get enrolled factors
authManager.getEnrolledFactors { result in
    switch result {
    case .success(let factors):
        print("✅ Enrolled factors: \(factors.count)")
        for factor in factors {
            print("Factor: \(factor.displayName)")
        }
    case .failure(let error):
        print("❌ Factor retrieval failed: \(error)")
    }
}

// Unenroll factor
authManager.unenrollFactor(factorID: "factor-id") { result in
    switch result {
    case .success:
        print("✅ Factor unenrolled")
    case .failure(let error):
        print("❌ Factor unenrollment failed: \(error)")
    }
}
```

---

## 🚪 Sign Out

### Sign Out Methods

```swift
// Sign out current user
authManager.signOut { result in
    switch result {
    case .success:
        print("✅ User signed out successfully")
    case .failure(let error):
        print("❌ Sign out failed: \(error)")
    }
}

// Sign out from specific provider
authManager.signOutFromProvider(.google) { result in
    switch result {
    case .success:
        print("✅ Signed out from Google")
    case .failure(let error):
        print("❌ Google sign out failed: \(error)")
    }
}

// Sign out from all providers
authManager.signOutFromAllProviders { result in
    switch result {
    case .success:
        print("✅ Signed out from all providers")
    case .failure(let error):
        print("❌ Sign out failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### Authentication Configuration

```swift
// Configure authentication settings
let authConfig = FirebaseAuthConfiguration()

// Enable authentication methods
authConfig.enableGoogleSignIn = true
authConfig.enableEmailPassword = true
authConfig.enablePhoneAuth = true
authConfig.enableAnonymousAuth = true
authConfig.enableMultiFactor = true

// Set authentication settings
authConfig.requireEmailVerification = true
authConfig.allowAnonymousUpgrade = true
authConfig.sessionTimeoutDuration = 3600
authConfig.maxLoginAttempts = 5

// Apply configuration
authManager.configure(authConfig) { result in
    switch result {
    case .success:
        print("✅ Authentication configured")
    case .failure(let error):
        print("❌ Configuration failed: \(error)")
    }
}
```

### Security Configuration

```swift
// Configure security settings
let securityConfig = AuthSecurityConfiguration()
securityConfig.enablePasswordValidation = true
securityConfig.minPasswordLength = 8
securityConfig.requireSpecialCharacters = true
securityConfig.requireNumbers = true
securityConfig.requireUppercase = true

// Apply security configuration
authManager.configureSecurity(securityConfig) { result in
    switch result {
    case .success:
        print("✅ Security configured")
    case .failure(let error):
        print("❌ Security configuration failed: \(error)")
    }
}
```

---

## 🛡️ Security Best Practices

### Password Security

- Enforce strong password requirements
- Implement password validation
- Use secure password reset flows
- Monitor failed login attempts

### Session Management

- Implement proper session timeouts
- Use secure token storage
- Implement automatic logout
- Monitor suspicious activity

### Data Protection

- Encrypt sensitive user data
- Implement proper data deletion
- Follow privacy regulations
- Use secure communication

---

## 🔗 Related Documentation

- [Authentication API](AuthenticationAPI.md)
- [Getting Started Guide](GettingStarted.md)
- [Security Guide](SecurityGuide.md)
- [Configuration API](ConfigurationAPI.md)
- [Integration API](IntegrationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
