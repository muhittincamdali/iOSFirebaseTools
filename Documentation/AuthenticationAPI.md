# Authentication API

## Overview

The Authentication API provides comprehensive Firebase authentication capabilities for iOS applications.

## Core Features

- **Email/Password**: Traditional email and password authentication
- **Social Authentication**: Google, Facebook, Twitter, Apple Sign-In
- **Anonymous Authentication**: Guest user authentication
- **Phone Authentication**: SMS-based authentication
- **Multi-Factor Authentication**: Enhanced security with 2FA

## Usage

```swift
import iOSFirebaseTools

let authManager = FirebaseAuthManager()

// Email/Password authentication
authManager.signIn(email: "user@example.com", password: "password") { result in
    switch result {
    case .success(let user):
        print("✅ Authentication successful")
    case .failure(let error):
        print("❌ Authentication failed: \(error)")
    }
}

// Anonymous authentication
authManager.signInAnonymously { result in
    // Handle result
}
```

## Authentication Methods

- **Email/Password**: Traditional authentication
- **Social**: Google, Facebook, Twitter, Apple
- **Anonymous**: Guest user access
- **Phone**: SMS verification
- **Multi-Factor**: Enhanced security
