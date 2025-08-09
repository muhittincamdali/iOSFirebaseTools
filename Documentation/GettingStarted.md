# Getting Started

<!-- TOC START -->
## Table of Contents
- [Getting Started](#getting-started)
- [🚀 Quick Start Guide](#-quick-start-guide)
- [📋 Prerequisites](#-prerequisites)
- [🔧 Installation](#-installation)
  - [1. Create Firebase Project](#1-create-firebase-project)
  - [2. Add iOS App to Firebase](#2-add-ios-app-to-firebase)
  - [3. Install iOS Firebase Tools](#3-install-ios-firebase-tools)
    - [Swift Package Manager](#swift-package-manager)
    - [CocoaPods](#cocoapods)
- [⚡ Basic Setup](#-basic-setup)
  - [1. Import the Framework](#1-import-the-framework)
  - [2. Initialize Firebase Tools](#2-initialize-firebase-tools)
  - [3. Configure Firebase Project](#3-configure-firebase-project)
- [🔐 Authentication Setup](#-authentication-setup)
  - [1. Configure Authentication](#1-configure-authentication)
  - [2. First Sign-In](#2-first-sign-in)
- [🗄️ Firestore Setup](#-firestore-setup)
  - [1. Configure Firestore](#1-configure-firestore)
  - [2. First Database Operation](#2-first-database-operation)
- [📱 Cloud Messaging Setup](#-cloud-messaging-setup)
  - [1. Configure Cloud Messaging](#1-configure-cloud-messaging)
  - [2. Register for Notifications](#2-register-for-notifications)
- [📊 Analytics Setup](#-analytics-setup)
  - [1. Configure Analytics](#1-configure-analytics)
  - [2. First Analytics Event](#2-first-analytics-event)
- [🎯 Complete Example](#-complete-example)
- [🔧 Configuration Files](#-configuration-files)
  - [GoogleService-Info.plist](#googleservice-infoplist)
  - [Info.plist Configuration](#infoplist-configuration)
- [🚨 Troubleshooting](#-troubleshooting)
  - [Common Issues](#common-issues)
    - [1. Build Errors](#1-build-errors)
- [Clean build folder](#clean-build-folder)
- [Reset package cache](#reset-package-cache)
- [Update dependencies](#update-dependencies)
    - [2. Configuration Issues](#2-configuration-issues)
    - [3. Permission Issues](#3-permission-issues)
  - [Debug Mode](#debug-mode)
- [📚 Next Steps](#-next-steps)
  - [Recommended Reading](#recommended-reading)
- [🔗 Related Documentation](#-related-documentation)
- [📞 Support](#-support)
<!-- TOC END -->


## 🚀 Quick Start Guide

Complete guide to get started with iOS Firebase Tools in your iOS application.

---

## 📋 Prerequisites

Before you begin, ensure you have the following:

- **iOS 15.0+** with iOS 15.0+ SDK
- **Swift 5.9+** programming language
- **Xcode 15.0+** development environment
- **Firebase Project** with configured services
- **Git** version control system
- **Swift Package Manager** for dependency management

---

## 🔧 Installation

### 1. Create Firebase Project

First, create a Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter your project name
4. Follow the setup wizard
5. Enable the services you need (Authentication, Firestore, etc.)

### 2. Add iOS App to Firebase

1. In Firebase Console, click "Add app"
2. Select iOS platform
3. Enter your bundle identifier
4. Download `GoogleService-Info.plist`
5. Add the file to your Xcode project

### 3. Install iOS Firebase Tools

#### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "1.0.0")
]
```

Or add via Xcode:

1. Go to File → Add Package Dependencies
2. Enter: `https://github.com/muhittincamdali/iOSFirebaseTools.git`
3. Select version: `1.0.0`
4. Add to your target

#### CocoaPods

Add to your `Podfile`:

```ruby
pod 'iOSFirebaseTools', '~> 1.0.0'
```

Then run:

```bash
pod install
```

---

## ⚡ Basic Setup

### 1. Import the Framework

```swift
import iOSFirebaseTools
```

### 2. Initialize Firebase Tools

```swift
// Initialize Firebase tools manager
let firebaseToolsManager = FirebaseToolsManager.shared

// Configure Firebase tools
let firebaseConfig = FirebaseToolsConfiguration()
firebaseConfig.enableAuthentication = true
firebaseConfig.enableFirestore = true
firebaseConfig.enableCloudMessaging = true
firebaseConfig.enableAnalytics = true

// Start Firebase tools manager
firebaseToolsManager.start(with: firebaseConfig) { result in
    switch result {
    case .success:
        print("✅ Firebase Tools initialized successfully")
    case .failure(let error):
        print("❌ Firebase Tools initialization failed: \(error)")
    }
}
```

### 3. Configure Firebase Project

```swift
// Configure Firebase project
firebaseToolsManager.configureProject { config in
    config.projectID = "your-firebase-project-id"
    config.enableCrashlytics = true
    config.enablePerformance = true
    config.enableAnalytics = true
} { result in
    switch result {
    case .success:
        print("✅ Firebase project configured")
    case .failure(let error):
        print("❌ Project configuration failed: \(error)")
    }
}
```

---

## 🔐 Authentication Setup

### 1. Configure Authentication

```swift
// Initialize authentication manager
let authManager = FirebaseAuthManager.shared

// Configure authentication
let authConfig = FirebaseAuthConfiguration()
authConfig.enableGoogleSignIn = true
authConfig.enableEmailPassword = true
authConfig.enablePhoneAuth = true
authConfig.enableAnonymousAuth = true

authManager.configure(authConfig) { result in
    switch result {
    case .success:
        print("✅ Authentication configured")
    case .failure(let error):
        print("❌ Authentication configuration failed: \(error)")
    }
}
```

### 2. First Sign-In

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

## 🗄️ Firestore Setup

### 1. Configure Firestore

```swift
// Initialize Firestore manager
let firestoreManager = FirestoreManager.shared

// Configure Firestore
let firestoreConfig = FirestoreConfiguration()
firestoreConfig.enableOfflineSupport = true
firestoreConfig.enableCaching = true
firestoreConfig.enableSecurityRules = true
firestoreConfig.enableRealTimeUpdates = true

firestoreManager.configure(firestoreConfig) { result in
    switch result {
    case .success:
        print("✅ Firestore configured")
    case .failure(let error):
        print("❌ Firestore configuration failed: \(error)")
    }
}
```

### 2. First Database Operation

```swift
// Add document to Firestore
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "createdAt": FieldValue.serverTimestamp()
]

firestoreManager.addDocument(
    collection: "users",
    data: userData
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

## 📱 Cloud Messaging Setup

### 1. Configure Cloud Messaging

```swift
// Initialize FCM manager
let fcmManager = FirebaseCloudMessagingManager.shared

// Configure FCM
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true
fcmConfig.enableTopicMessaging = true

fcmManager.configure(fcmConfig) { result in
    switch result {
    case .success:
        print("✅ FCM configured")
    case .failure(let error):
        print("❌ FCM configuration failed: \(error)")
    }
}
```

### 2. Register for Notifications

```swift
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
```

---

## 📊 Analytics Setup

### 1. Configure Analytics

```swift
// Initialize analytics manager
let analyticsManager = FirebaseAnalyticsManager.shared

// Configure analytics
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableUserProperties = true
analyticsConfig.enableCustomEvents = true
analyticsConfig.enableConversionTracking = true
analyticsConfig.enableAudienceSegmentation = true

analyticsManager.configure(analyticsConfig) { result in
    switch result {
    case .success:
        print("✅ Analytics configured")
    case .failure(let error):
        print("❌ Analytics configuration failed: \(error)")
    }
}
```

### 2. First Analytics Event

```swift
// Log custom event
analyticsManager.logEvent(
    name: "app_opened",
    parameters: [
        "user_type": "new",
        "app_version": "1.0.0"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Analytics event logged")
    case .failure(let error):
        print("❌ Analytics event failed: \(error)")
    }
}
```

---

## 🎯 Complete Example

Here's a complete example showing all services working together:

```swift
import iOSFirebaseTools

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase Tools
        let firebaseToolsManager = FirebaseToolsManager.shared
        
        // Configure all services
        let firebaseConfig = FirebaseToolsConfiguration()
        firebaseConfig.enableAuthentication = true
        firebaseConfig.enableFirestore = true
        firebaseConfig.enableCloudMessaging = true
        firebaseConfig.enableAnalytics = true
        
        // Start Firebase Tools
        firebaseToolsManager.start(with: firebaseConfig) { result in
            switch result {
            case .success:
                print("✅ Firebase Tools started")
                self.setupServices()
            case .failure(let error):
                print("❌ Firebase Tools start failed: \(error)")
            }
        }
        
        return true
    }
    
    private func setupServices() {
        // Setup Authentication
        let authManager = FirebaseAuthManager.shared
        let authConfig = FirebaseAuthConfiguration()
        authConfig.enableEmailPassword = true
        authConfig.enableGoogleSignIn = true
        
        authManager.configure(authConfig) { result in
            switch result {
            case .success:
                print("✅ Authentication ready")
            case .failure(let error):
                print("❌ Authentication setup failed: \(error)")
            }
        }
        
        // Setup Firestore
        let firestoreManager = FirestoreManager.shared
        let firestoreConfig = FirestoreConfiguration()
        firestoreConfig.enableOfflineSupport = true
        
        firestoreManager.configure(firestoreConfig) { result in
            switch result {
            case .success:
                print("✅ Firestore ready")
            case .failure(let error):
                print("❌ Firestore setup failed: \(error)")
            }
        }
        
        // Setup Cloud Messaging
        let fcmManager = FirebaseCloudMessagingManager.shared
        let fcmConfig = FCMConfiguration()
        fcmConfig.enableNotifications = true
        
        fcmManager.configure(fcmConfig) { result in
            switch result {
            case .success:
                print("✅ FCM ready")
                fcmManager.registerForRemoteNotifications { result in
                    switch result {
                    case .success(let token):
                        print("✅ FCM token: \(token)")
                    case .failure(let error):
                        print("❌ FCM registration failed: \(error)")
                    }
                }
            case .failure(let error):
                print("❌ FCM setup failed: \(error)")
            }
        }
        
        // Setup Analytics
        let analyticsManager = FirebaseAnalyticsManager.shared
        let analyticsConfig = AnalyticsConfiguration()
        analyticsConfig.enableCustomEvents = true
        
        analyticsManager.configure(analyticsConfig) { result in
            switch result {
            case .success:
                print("✅ Analytics ready")
                analyticsManager.logEvent("app_launched") { _ in }
            case .failure(let error):
                print("❌ Analytics setup failed: \(error)")
            }
        }
    }
}
```

---

## 🔧 Configuration Files

### GoogleService-Info.plist

Make sure your `GoogleService-Info.plist` is properly configured:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>your-api-key</string>
    <key>GCM_SENDER_ID</key>
    <string>your-sender-id</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.yourcompany.yourapp</string>
    <key>PROJECT_ID</key>
    <string>your-project-id</string>
    <key>STORAGE_BUCKET</key>
    <string>your-project-id.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false/>
    <key>IS_ANALYTICS_ENABLED</key>
    <true/>
    <key>IS_APPINVITE_ENABLED</key>
    <true/>
    <key>IS_GCM_ENABLED</key>
    <true/>
    <key>IS_SIGNIN_ENABLED</key>
    <true/>
    <key>GOOGLE_APP_ID</key>
    <string>your-app-id</string>
</dict>
</plist>
```

### Info.plist Configuration

Add required permissions to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your-reversed-client-id</string>
        </array>
    </dict>
</array>
```

---

## 🚨 Troubleshooting

### Common Issues

#### 1. Build Errors

If you encounter build errors:

```bash
# Clean build folder
Xcode → Product → Clean Build Folder

# Reset package cache
File → Packages → Reset Package Caches

# Update dependencies
File → Packages → Update to Latest Package Versions
```

#### 2. Configuration Issues

If services aren't working:

1. Verify `GoogleService-Info.plist` is in your project
2. Check bundle identifier matches Firebase project
3. Ensure services are enabled in Firebase Console
4. Verify network connectivity

#### 3. Permission Issues

For notification permissions:

1. Check `Info.plist` has required permissions
2. Request permissions at runtime
3. Handle permission denied gracefully

### Debug Mode

Enable debug mode for development:

```swift
#if DEBUG
let debugConfig = FirebaseToolsConfiguration()
debugConfig.enableDebugMode = true
debugConfig.enableLogging = true

firebaseToolsManager.configure(debugConfig) { result in
    switch result {
    case .success:
        print("✅ Debug mode enabled")
    case .failure(let error):
        print("❌ Debug mode failed: \(error)")
    }
}
#endif
```

---

## 📚 Next Steps

Now that you have basic setup complete:

1. **Authentication**: Implement user sign-in/sign-up flows
2. **Firestore**: Set up your database structure
3. **Cloud Messaging**: Configure push notifications
4. **Analytics**: Track user behavior and app performance
5. **Security**: Implement proper security rules
6. **Testing**: Add comprehensive tests

### Recommended Reading

- [Authentication Guide](AuthenticationGuide.md)
- [Firestore Guide](FirestoreGuide.md)
- [Cloud Messaging Guide](CloudMessagingGuide.md)
- [Analytics Guide](AnalyticsGuide.md)
- [Security Guide](SecurityGuide.md)

---

## 🔗 Related Documentation

- [Authentication API](AuthenticationAPI.md)
- [Firestore API](FirestoreAPI.md)
- [Cloud Messaging API](CloudMessagingAPI.md)
- [Analytics API](AnalyticsAPI.md)
- [Configuration API](ConfigurationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
