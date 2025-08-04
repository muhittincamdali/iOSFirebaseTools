# iOS Firebase Tools

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-red.svg)](CHANGELOG.md)

A comprehensive collection of Firebase tools and utilities for iOS development, providing easy-to-use wrappers and extensions for Firebase services.

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### 🔐 Authentication Tools
- **FirebaseAuthManager**: Complete authentication management
- **SocialAuthProvider**: Social media authentication
- **BiometricAuth**: Face ID and Touch ID integration
- **AuthStateListener**: Real-time authentication state monitoring

### 📊 Analytics Tools
- **FirebaseAnalyticsManager**: Event tracking and user properties
- **CustomEventTracker**: Custom analytics events
- **ScreenTracker**: Automatic screen tracking
- **PerformanceTracker**: App performance monitoring

### 💾 Firestore Tools
- **FirestoreManager**: Database operations and queries
- **RealtimeListener**: Real-time data synchronization
- **OfflineSupport**: Offline data persistence
- **BatchOperations**: Bulk data operations

### 🗄️ Storage Tools
- **FirebaseStorageManager**: File upload and download
- **ImageUploader**: Image optimization and upload
- **FileManager**: File management utilities
- **CacheManager**: Local caching system

### 🔔 Messaging Tools
- **FirebaseMessagingManager**: Push notification handling
- **NotificationHandler**: Notification display and interaction
- **TopicManager**: Topic subscription management
- **TokenManager**: Device token management

### 🛡️ Security Tools
- **SecurityRules**: Firestore security rules
- **DataEncryption**: End-to-end encryption
- **AccessControl**: Role-based access control
- **AuditLogger**: Security audit logging

## 📱 Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Firebase SDK 10.18.0+

## 🚀 Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/iOSFirebaseTools.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/your-username/iOSFirebaseTools.git`
3. Select version: `1.0.0`

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'iOSFirebaseTools', '~> 1.0.0'
```

### Carthage

Add to your `Cartfile`:

```
github "your-username/iOSFirebaseTools" ~> 1.0.0
```

## ⚡ Quick Start

### 1. Setup Firebase

First, configure Firebase in your project:

```swift
import iOSFirebaseTools

// Initialize Firebase
FirebaseTools.initialize()
```

### 2. Authentication

```swift
import iOSFirebaseTools

// Sign in with email and password
do {
    let user = try await FirebaseAuthManager.shared.signIn(
        email: "user@example.com",
        password: "password123"
    )
    print("Signed in: \(user.displayName)")
} catch {
    print("Sign in failed: \(error)")
}

// Social authentication
do {
    let user = try await SocialAuthProvider.shared.signInWithApple()
    print("Apple sign in successful")
} catch {
    print("Apple sign in failed: \(error)")
}
```

### 3. Firestore Operations

```swift
import iOSFirebaseTools

// Create a document
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
]

do {
    try await FirestoreManager.shared.createDocument(
        collection: "users",
        data: userData
    )
    print("Document created successfully")
} catch {
    print("Failed to create document: \(error)")
}

// Query documents
do {
    let users = try await FirestoreManager.shared.queryDocuments(
        collection: "users",
        where: [("age", ">=", 25)]
    )
    print("Found \(users.count) users")
} catch {
    print("Query failed: \(error)")
}
```

### 4. Analytics

```swift
import iOSFirebaseTools

// Track custom event
FirebaseAnalyticsManager.shared.trackEvent(
    name: "purchase_completed",
    parameters: [
        "product_id": "123",
        "price": 99.99,
        "currency": "USD"
    ]
)

// Set user property
FirebaseAnalyticsManager.shared.setUserProperty(
    key: "subscription_type",
    value: "premium"
)
```

### 5. Storage

```swift
import iOSFirebaseTools

// Upload image
let imageData = UIImage(named: "profile")?.jpegData(compressionQuality: 0.8)

do {
    let downloadURL = try await FirebaseStorageManager.shared.uploadImage(
        data: imageData!,
        path: "users/\(userId)/profile.jpg"
    )
    print("Image uploaded: \(downloadURL)")
} catch {
    print("Upload failed: \(error)")
}
```

### 6. Messaging

```swift
import iOSFirebaseTools

// Subscribe to topic
FirebaseMessagingManager.shared.subscribeToTopic("news")

// Handle notification
FirebaseMessagingManager.shared.handleNotification { notification in
    print("Received notification: \(notification.title)")
}
```

## 📚 Documentation

### [Getting Started Guide](Documentation/GettingStarted.md)
Complete setup and configuration guide.

### [Authentication Guide](Documentation/AuthenticationGuide.md)
Comprehensive authentication implementation.

### [Firestore Guide](Documentation/FirestoreGuide.md)
Database operations and real-time synchronization.

### [Analytics Guide](Documentation/AnalyticsGuide.md)
Event tracking and user analytics.

### [Storage Guide](Documentation/StorageGuide.md)
File upload, download, and management.

### [Messaging Guide](Documentation/MessagingGuide.md)
Push notifications and messaging.

### [Security Guide](Documentation/SecurityGuide.md)
Security rules and data protection.

### [API Reference](Documentation/API.md)
Complete API documentation.

## 🎯 Examples

### [Basic Example](Examples/BasicExample/)
Simple Firebase integration example.

### [Advanced Example](Examples/AdvancedExample/)
Complex Firebase features implementation.

### [Custom Example](Examples/CustomExample/)
Custom Firebase implementation.

## 🛠️ Architecture

```
iOSFirebaseTools/
├── Sources/
│   ├── Authentication/
│   │   ├── FirebaseAuthManager.swift
│   │   ├── SocialAuthProvider.swift
│   │   ├── BiometricAuth.swift
│   │   └── AuthStateListener.swift
│   ├── Analytics/
│   │   ├── FirebaseAnalyticsManager.swift
│   │   ├── CustomEventTracker.swift
│   │   ├── ScreenTracker.swift
│   │   └── PerformanceTracker.swift
│   ├── Firestore/
│   │   ├── FirestoreManager.swift
│   │   ├── RealtimeListener.swift
│   │   ├── OfflineSupport.swift
│   │   └── BatchOperations.swift
│   ├── Storage/
│   │   ├── FirebaseStorageManager.swift
│   │   ├── ImageUploader.swift
│   │   ├── FileManager.swift
│   │   └── CacheManager.swift
│   ├── Messaging/
│   │   ├── FirebaseMessagingManager.swift
│   │   ├── NotificationHandler.swift
│   │   ├── TopicManager.swift
│   │   └── TokenManager.swift
│   ├── Security/
│   │   ├── SecurityRules.swift
│   │   ├── DataEncryption.swift
│   │   ├── AccessControl.swift
│   │   └── AuditLogger.swift
│   └── iOSFirebaseTools/
│       └── iOSFirebaseTools.swift
├── Documentation/
├── Examples/
├── Tests/
└── Resources/
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful names
- Add documentation comments
- Write unit tests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**⭐ Star this repository if it helped you!**

## 📊 Project Statistics

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/muhittincamdali/iOSFirebaseTools?style=social)](https://github.com/muhittincamdali/iOSFirebaseTools/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/muhittincamdali/iOSFirebaseTools?style=social)](https://github.com/muhittincamdali/iOSFirebaseTools/network)
[![GitHub issues](https://img.shields.io/github/issues/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/pulls)

</div>

## 🌟 Stargazers

[![Stargazers repo roster for @muhittincamdali/iOSFirebaseTools](https://reporoster.com/stars/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/stargazers)

## 🙏 Acknowledgments

- [Firebase](https://firebase.google.com/) for the amazing platform
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the modern UI framework
- The iOS development community for inspiration and feedback

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/iOSFirebaseTools/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/iOSFirebaseTools/discussions)
- **Documentation**: [Documentation](Documentation/)
- **Examples**: [Examples](Examples/)

---

**Made with ❤️ for the iOS development community** 