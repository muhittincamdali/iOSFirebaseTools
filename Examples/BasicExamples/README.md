# Basic Examples

This directory contains basic examples for iOS Firebase Tools.

## Examples

- **SimpleAuthentication.swift** - Basic Firebase authentication
- **SimpleFirestore.swift** - Basic Firestore operations
- **SimpleAnalytics.swift** - Basic analytics tracking

## Usage

```swift
import iOSFirebaseTools

// Basic Firebase authentication
let authManager = FirebaseAuthManager()
authManager.signInAnonymously { result in
    // Handle result
}
```

## Getting Started

1. Import the framework
2. Configure Firebase
3. Initialize managers
4. Implement features
5. Handle results
