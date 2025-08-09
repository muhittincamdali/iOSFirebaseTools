# 🔥 iOS Firebase Tools

<!-- TOC START -->
## Table of Contents
- [🔥 iOS Firebase Tools](#-ios-firebase-tools)
- [📋 Table of Contents](#-table-of-contents)
- [🚀 Overview](#-overview)
  - [🎯 What Makes This Collection Special?](#-what-makes-this-collection-special)
- [✨ Key Features](#-key-features)
  - [🔐 Authentication](#-authentication)
  - [🗄️ Firestore](#-firestore)
  - [📱 Cloud Messaging](#-cloud-messaging)
  - [📊 Analytics](#-analytics)
- [🔐 Authentication](#-authentication)
  - [Firebase Authentication Manager](#firebase-authentication-manager)
  - [User Management](#user-management)
- [🗄️ Firestore](#-firestore)
  - [Firestore Database Manager](#firestore-database-manager)
  - [Real-Time Listeners](#real-time-listeners)
- [📱 Cloud Messaging](#-cloud-messaging)
  - [Firebase Cloud Messaging Manager](#firebase-cloud-messaging-manager)
  - [Notification Handling](#notification-handling)
- [📊 Analytics](#-analytics)
  - [Firebase Analytics Manager](#firebase-analytics-manager)
  - [Performance Monitoring](#performance-monitoring)
- [🚀 Quick Start](#-quick-start)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Clone the repository](#clone-the-repository)
- [Navigate to project directory](#navigate-to-project-directory)
- [Install dependencies](#install-dependencies)
- [Open in Xcode](#open-in-xcode)
  - [Swift Package Manager](#swift-package-manager)
  - [Basic Setup](#basic-setup)
- [📱 Usage Examples](#-usage-examples)
  - [Simple Authentication](#simple-authentication)
  - [Simple Firestore](#simple-firestore)
- [🔧 Configuration](#-configuration)
  - [Firebase Tools Configuration](#firebase-tools-configuration)
- [📚 Documentation](#-documentation)
  - [API Documentation](#api-documentation)
  - [Integration Guides](#integration-guides)
  - [Examples](#examples)
- [🤝 Contributing](#-contributing)
  - [Development Setup](#development-setup)
  - [Code Standards](#code-standards)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [📊 Project Statistics](#-project-statistics)
- [🌟 Stargazers](#-stargazers)
<!-- TOC END -->


<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=ios&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Platform-4CAF50?style=for-the-badge)
![Authentication](https://img.shields.io/badge/Authentication-Google-2196F3?style=for-the-badge)
![Firestore](https://img.shields.io/badge/Firestore-Database-FF9800?style=for-the-badge)
![Cloud Messaging](https://img.shields.io/badge/Cloud%20Messaging-Push-9C27B0?style=for-the-badge)
![Analytics](https://img.shields.io/badge/Analytics-Tracking-00BCD4?style=for-the-badge)
![Crashlytics](https://img.shields.io/badge/Crashlytics-Reporting-607D8B?style=for-the-badge)
![Performance](https://img.shields.io/badge/Performance-Monitoring-795548?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean-FF5722?style=for-the-badge)
![Swift Package Manager](https://img.shields.io/badge/SPM-Dependencies-FF6B35?style=for-the-badge)
![CocoaPods](https://img.shields.io/badge/CocoaPods-Supported-E91E63?style=for-the-badge)

**🏆 Professional iOS Firebase Tools Collection**

**🔥 Comprehensive Firebase Integration Tools**

**⚡ Accelerate Your Firebase Development**

</div>

---

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [✨ Key Features](#-key-features)
- [🔐 Authentication](#-authentication)
- [🗄️ Firestore](#-firestore)
- [📱 Cloud Messaging](#-cloud-messaging)
- [📊 Analytics](#-analytics)
- [🚀 Quick Start](#-quick-start)
- [📱 Usage Examples](#-usage-examples)
- [🔧 Configuration](#-configuration)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [📊 Project Statistics](#-project-statistics)
- [🌟 Stargazers](#-stargazers)

---

## 🚀 Overview

**iOS Firebase Tools** is the most comprehensive, professional, and feature-rich collection of Firebase integration tools for iOS applications. Built with enterprise-grade standards and modern Firebase development practices, this collection provides essential tools for authentication, database management, messaging, analytics, and more.

### 🎯 What Makes This Collection Special?

- **🔐 Authentication**: Complete Firebase Authentication integration
- **🗄️ Firestore**: Advanced Firestore database management
- **📱 Cloud Messaging**: Push notification and messaging tools
- **📊 Analytics**: Comprehensive analytics and tracking
- **🚨 Crashlytics**: Crash reporting and analysis
- **⚡ Performance**: Performance monitoring and optimization
- **🔧 Configuration**: Easy Firebase configuration and setup
- **🎯 Integration**: Seamless Firebase service integration

---

## ✨ Key Features

### 🔐 Authentication

* **Google Sign-In**: Complete Google authentication integration
* **Email/Password**: Traditional email and password authentication
* **Phone Authentication**: SMS-based phone authentication
* **Anonymous Auth**: Anonymous user authentication
* **Social Login**: Facebook, Twitter, and other social logins
* **Multi-Factor Auth**: Multi-factor authentication support
* **Custom Tokens**: Custom authentication token handling
* **User Management**: Complete user management system

### 🗄️ Firestore

* **Real-Time Database**: Real-time data synchronization
* **Offline Support**: Offline data persistence and sync
* **Security Rules**: Advanced security rule management
* **Data Modeling**: Flexible data modeling and structure
* **Query Optimization**: Advanced query optimization
* **Batch Operations**: Batch read and write operations
* **Transaction Support**: ACID transaction support
* **Data Migration**: Database migration and versioning

### 📱 Cloud Messaging

* **Push Notifications**: Complete push notification system
* **Topic Messaging**: Topic-based messaging
* **Direct Messaging**: Direct user-to-user messaging
* **Rich Notifications**: Rich notification content
* **Silent Notifications**: Background notification processing
* **Notification Actions**: Interactive notification actions
* **Badge Management**: App badge management
* **Sound & Vibration**: Custom sound and vibration

### 📊 Analytics

* **User Analytics**: Comprehensive user behavior analytics
* **Event Tracking**: Custom event tracking and analysis
* **Conversion Tracking**: Conversion funnel analysis
* **Audience Segmentation**: User audience segmentation
* **Real-Time Analytics**: Real-time analytics dashboard
* **Custom Dimensions**: Custom analytics dimensions
* **A/B Testing**: A/B testing and experimentation
* **Performance Analytics**: App performance analytics

---

## 🔐 Authentication

### Firebase Authentication Manager

```swift
// Firebase authentication manager
let authManager = FirebaseAuthManager()

// Configure authentication
let authConfig = FirebaseAuthConfiguration()
authConfig.enableGoogleSignIn = true
authConfig.enableEmailPassword = true
authConfig.enablePhoneAuth = true
authConfig.enableAnonymousAuth = true
authConfig.enableMultiFactor = true

// Setup authentication
authManager.configure(authConfig)

// Sign in with Google
authManager.signInWithGoogle { result in
    switch result {
    case .success(let user):
        print("✅ Google sign-in successful")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
        print("Display name: \(user.displayName)")
    case .failure(let error):
        print("❌ Google sign-in failed: \(error)")
    }
}

// Sign in with email and password
authManager.signInWithEmail(
    email: "user@company.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Email sign-in successful")
        print("User ID: \(user.uid)")
        print("Email: \(user.email)")
    case .failure(let error):
        print("❌ Email sign-in failed: \(error)")
    }
}

// Sign in with phone number
authManager.signInWithPhone(
    phoneNumber: "+1234567890"
) { result in
    switch result {
    case .success(let verificationID):
        print("✅ Phone verification sent")
        print("Verification ID: \(verificationID)")
    case .failure(let error):
        print("❌ Phone sign-in failed: \(error)")
    }
}
```

### User Management

```swift
// User management manager
let userManager = FirebaseUserManager()

// Get current user
if let currentUser = userManager.getCurrentUser() {
    print("Current user: \(currentUser.uid)")
    print("Email: \(currentUser.email)")
    print("Display name: \(currentUser.displayName)")
    
    // Update user profile
    let profileUpdates = UserProfileChangeRequest()
    profileUpdates.displayName = "John Doe"
    profileUpdates.photoURL = URL(string: "https://example.com/photo.jpg")
    
    userManager.updateProfile(profileUpdates) { result in
        switch result {
        case .success:
            print("✅ User profile updated")
        case .failure(let error):
            print("❌ Profile update failed: \(error)")
        }
    }
}

// Sign out
authManager.signOut { result in
    switch result {
    case .success:
        print("✅ User signed out")
    case .failure(let error):
        print("❌ Sign out failed: \(error)")
    }
}
```

---

## 🗄️ Firestore

### Firestore Database Manager

```swift
// Firestore database manager
let firestoreManager = FirestoreManager()

// Configure Firestore
let firestoreConfig = FirestoreConfiguration()
firestoreConfig.enableOfflineSupport = true
firestoreConfig.enableCaching = true
firestoreConfig.enableSecurityRules = true
firestoreConfig.enableRealTimeUpdates = true

// Setup Firestore
firestoreManager.configure(firestoreConfig)

// Add document to Firestore
let userData = [
    "name": "John Doe",
    "email": "john@company.com",
    "age": 30,
    "createdAt": FieldValue.serverTimestamp()
]

firestoreManager.addDocument(
    collection: "users",
    data: userData
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added successfully")
        print("Document ID: \(documentID)")
    case .failure(let error):
        print("❌ Document addition failed: \(error)")
    }
}

// Get document from Firestore
firestoreManager.getDocument(
    collection: "users",
    documentID: "user123"
) { result in
    switch result {
    case .success(let document):
        print("✅ Document retrieved successfully")
        print("Data: \(document.data())")
    case .failure(let error):
        print("❌ Document retrieval failed: \(error)")
    }
}

// Update document
let updateData = [
    "age": 31,
    "updatedAt": FieldValue.serverTimestamp()
]

firestoreManager.updateDocument(
    collection: "users",
    documentID: "user123",
    data: updateData
) { result in
    switch result {
    case .success:
        print("✅ Document updated successfully")
    case .failure(let error):
        print("❌ Document update failed: \(error)")
    }
}
```

### Real-Time Listeners

```swift
// Real-time listener manager
let listenerManager = FirestoreListenerManager()

// Listen for real-time updates
listenerManager.listenToDocument(
    collection: "users",
    documentID: "user123"
) { result in
    switch result {
    case .success(let document):
        print("📡 Real-time update received")
        print("Data: \(document.data())")
    case .failure(let error):
        print("❌ Real-time listener failed: \(error)")
    }
}

// Listen for collection changes
listenerManager.listenToCollection(
    collection: "users",
    query: Query.whereField("age", isGreaterThan: 25)
) { result in
    switch result {
    case .success(let documents):
        print("📡 Collection update received")
        print("Documents: \(documents.count)")
        for document in documents {
            print("Document: \(document.data())")
        }
    case .failure(let error):
        print("❌ Collection listener failed: \(error)")
    }
}
```

---

## 📱 Cloud Messaging

### Firebase Cloud Messaging Manager

```swift
// Firebase Cloud Messaging manager
let fcmManager = FirebaseCloudMessagingManager()

// Configure FCM
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true
fcmConfig.enableTopicMessaging = true

// Setup FCM
fcmManager.configure(fcmConfig)

// Register for remote notifications
fcmManager.registerForRemoteNotifications { result in
    switch result {
    case .success(let deviceToken):
        print("✅ Remote notifications registered")
        print("Device token: \(deviceToken)")
    case .failure(let error):
        print("❌ Remote notification registration failed: \(error)")
    }
}

// Subscribe to topic
fcmManager.subscribeToTopic("news") { result in
    switch result {
    case .success:
        print("✅ Subscribed to news topic")
    case .failure(let error):
        print("❌ Topic subscription failed: \(error)")
    }
}

// Send notification
let notification = FCMPushNotification(
    title: "New Message",
    body: "You have a new message",
    data: ["messageId": "123", "sender": "John"]
)

fcmManager.sendNotification(
    notification,
    to: "user_token_123"
) { result in
    switch result {
    case .success:
        print("✅ Push notification sent")
    case .failure(let error):
        print("❌ Push notification failed: \(error)")
    }
}
```

### Notification Handling

```swift
// Notification handler
let notificationHandler = FirebaseNotificationHandler()

// Handle incoming notifications
notificationHandler.onNotificationReceived { notification in
    print("📱 Notification received")
    print("Title: \(notification.title)")
    print("Body: \(notification.body)")
    print("Data: \(notification.data)")
    
    // Handle notification based on type
    if let messageId = notification.data["messageId"] {
        print("Message ID: \(messageId)")
        // Navigate to message
    }
}

// Handle notification actions
notificationHandler.onNotificationAction { action in
    print("🔘 Notification action: \(action.identifier)")
    
    switch action.identifier {
    case "reply":
        print("User tapped reply")
        // Handle reply action
    case "mark_read":
        print("User tapped mark as read")
        // Handle mark as read action
    default:
        print("Unknown action")
    }
}
```

---

## 📊 Analytics

### Firebase Analytics Manager

```swift
// Firebase Analytics manager
let analyticsManager = FirebaseAnalyticsManager()

// Configure analytics
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableUserProperties = true
analyticsConfig.enableCustomEvents = true
analyticsConfig.enableConversionTracking = true
analyticsConfig.enableAudienceSegmentation = true

// Setup analytics
analyticsManager.configure(analyticsConfig)

// Set user properties
analyticsManager.setUserProperty("premium", value: "true")
analyticsManager.setUserProperty("subscription_type", value: "monthly")

// Log custom event
analyticsManager.logEvent(
    name: "purchase_completed",
    parameters: [
        "item_id": "product_123",
        "price": 29.99,
        "currency": "USD",
        "category": "premium"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Custom event logged")
    case .failure(let error):
        print("❌ Event logging failed: \(error)")
    }
}

// Track screen view
analyticsManager.logScreenView(
    screenName: "ProductDetail",
    screenClass: "ProductDetailViewController"
) { result in
    switch result {
    case .success:
        print("✅ Screen view logged")
    case .failure(let error):
        print("❌ Screen view logging failed: \(error)")
    }
}
```

### Performance Monitoring

```swift
// Performance monitoring manager
let performanceManager = FirebasePerformanceManager()

// Configure performance monitoring
let performanceConfig = PerformanceConfiguration()
performanceConfig.enableNetworkMonitoring = true
performanceConfig.enableTraceMonitoring = true
performanceConfig.enableCustomTraces = true

// Setup performance monitoring
performanceManager.configure(performanceConfig)

// Start custom trace
let trace = performanceManager.startTrace("user_action")

// Add custom attributes
trace.setValue("button_tap", forAttribute: "action_type")
trace.setValue("home_screen", forAttribute: "screen")

// Stop trace
performanceManager.stopTrace(trace) { result in
    switch result {
    case .success:
        print("✅ Custom trace completed")
    case .failure(let error):
        print("❌ Trace completion failed: \(error)")
    }
}
```

---

## 🚀 Quick Start

### Prerequisites

* **iOS 15.0+** with iOS 15.0+ SDK
* **Swift 5.9+** programming language
* **Xcode 15.0+** development environment
* **Firebase Project** with configured services
* **Git** version control system
* **Swift Package Manager** for dependency management

### Installation

```bash
# Clone the repository
git clone https://github.com/muhittincamdali/iOSFirebaseTools.git

# Navigate to project directory
cd iOSFirebaseTools

# Install dependencies
swift package resolve

# Open in Xcode
open Package.swift
```

### Swift Package Manager

Add the framework to your project:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "1.0.0")
]
```

### Basic Setup

```swift
import iOSFirebaseTools

// Initialize Firebase tools manager
let firebaseToolsManager = FirebaseToolsManager()

// Configure Firebase tools
let firebaseConfig = FirebaseToolsConfiguration()
firebaseConfig.enableAuthentication = true
firebaseConfig.enableFirestore = true
firebaseConfig.enableCloudMessaging = true
firebaseConfig.enableAnalytics = true

// Start Firebase tools manager
firebaseToolsManager.start(with: firebaseConfig)

// Configure Firebase project
firebaseToolsManager.configureProject { config in
    config.projectID = "your-firebase-project-id"
    config.enableCrashlytics = true
    config.enablePerformance = true
}
```

---

## 📱 Usage Examples

### Simple Authentication

```swift
// Simple Firebase authentication
let simpleAuth = SimpleFirebaseAuth()

// Sign in with email
simpleAuth.signInWithEmail(
    email: "user@company.com",
    password: "password123"
) { result in
    switch result {
    case .success(let user):
        print("✅ Sign-in successful")
        print("User: \(user.email)")
    case .failure(let error):
        print("❌ Sign-in failed: \(error)")
    }
}
```

### Simple Firestore

```swift
// Simple Firestore operations
let simpleFirestore = SimpleFirestore()

// Add document
simpleFirestore.addDocument(
    collection: "users",
    data: ["name": "John", "email": "john@company.com"]
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added: \(documentID)")
    case .failure(let error):
        print("❌ Document addition failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### Firebase Tools Configuration

```swift
// Configure Firebase tools settings
let firebaseConfig = FirebaseToolsConfiguration()

// Enable Firebase services
firebaseConfig.enableAuthentication = true
firebaseConfig.enableFirestore = true
firebaseConfig.enableCloudMessaging = true
firebaseConfig.enableAnalytics = true

// Set authentication settings
firebaseConfig.enableGoogleSignIn = true
firebaseConfig.enableEmailPassword = true
firebaseConfig.enablePhoneAuth = true
firebaseConfig.enableAnonymousAuth = true

// Set Firestore settings
firebaseConfig.enableOfflineSupport = true
firebaseConfig.enableRealTimeUpdates = true
firebaseConfig.enableSecurityRules = true

// Set messaging settings
firebaseConfig.enablePushNotifications = true
firebaseConfig.enableTopicMessaging = true
firebaseConfig.enableRichNotifications = true

// Apply configuration
firebaseToolsManager.configure(firebaseConfig)
```

---

## 📚 Documentation

### API Documentation

Comprehensive API documentation is available for all public interfaces:

* [Firebase Tools Manager API](Documentation/FirebaseToolsManagerAPI.md) - Core Firebase tools functionality
* [Authentication API](Documentation/AuthenticationAPI.md) - Authentication features
* [Firestore API](Documentation/FirestoreAPI.md) - Firestore capabilities
* [Cloud Messaging API](Documentation/CloudMessagingAPI.md) - Cloud messaging features
* [Analytics API](Documentation/AnalyticsAPI.md) - Analytics capabilities
* [Performance API](Documentation/PerformanceAPI.md) - Performance monitoring
* [Configuration API](Documentation/ConfigurationAPI.md) - Configuration options
* [Integration API](Documentation/IntegrationAPI.md) - Integration capabilities

### Integration Guides

* [Getting Started Guide](Documentation/GettingStarted.md) - Quick start tutorial
* [Authentication Guide](Documentation/AuthenticationGuide.md) - Authentication setup
* [Firestore Guide](Documentation/FirestoreGuide.md) - Firestore setup
* [Cloud Messaging Guide](Documentation/CloudMessagingGuide.md) - Cloud messaging setup
* [Analytics Guide](Documentation/AnalyticsGuide.md) - Analytics setup
* [Performance Guide](Documentation/PerformanceGuide.md) - Performance monitoring
* [Security Guide](Documentation/SecurityGuide.md) - Security features

### Examples

* [Basic Examples](Examples/BasicExamples/) - Simple Firebase implementations
* [Advanced Examples](Examples/AdvancedExamples/) - Complex Firebase scenarios
* [Authentication Examples](Examples/AuthenticationExamples/) - Authentication examples
* [Firestore Examples](Examples/FirestoreExamples/) - Firestore examples
* [Cloud Messaging Examples](Examples/CloudMessagingExamples/) - Cloud messaging examples
* [Analytics Examples](Examples/AnalyticsExamples/) - Analytics examples

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Development Setup

1. **Fork** the repository
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open Pull Request**

### Code Standards

* Follow Swift API Design Guidelines
* Maintain 100% test coverage
* Use meaningful commit messages
* Update documentation as needed
* Follow Firebase development best practices
* Implement proper error handling
* Add comprehensive examples

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

* **Google** for the excellent Firebase platform
* **The Swift Community** for inspiration and feedback
* **All Contributors** who help improve this framework
* **Firebase Community** for best practices and standards
* **Open Source Community** for continuous innovation
* **iOS Developer Community** for Firebase insights
* **Mobile Development Community** for integration expertise

---

**⭐ Star this repository if it helped you!**

---

## 📊 Project Statistics

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/muhittincamdali/iOSFirebaseTools?style=social&logo=github)](https://github.com/muhittincamdali/iOSFirebaseTools/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/muhittincamdali/iOSFirebaseTools?style=social)](https://github.com/muhittincamdali/iOSFirebaseTools/network)
[![GitHub issues](https://img.shields.io/github/issues/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/pulls)
[![GitHub contributors](https://img.shields.io/github/contributors/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/graphs/contributors)
[![GitHub last commit](https://img.shields.io/github/last-commit/muhittincamdali/iOSFirebaseTools)](https://github.com/muhittincamdali/iOSFirebaseTools/commits/master)

</div>

## 🌟 Stargazers

[![Stargazers repo roster for @muhittincamdali/iOSFirebaseTools](https://starchart.cc/muhittincamdali/iOSFirebaseTools.svg)](https://github.com/muhittincamdali/iOSFirebaseTools/stargazers) 