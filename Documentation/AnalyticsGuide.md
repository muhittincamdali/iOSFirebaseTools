# Analytics Guide

<!-- TOC START -->
## Table of Contents
- [Analytics Guide](#analytics-guide)
- [📊 Firebase Analytics Integration Guide](#-firebase-analytics-integration-guide)
- [🚀 Quick Start](#-quick-start)
  - [1. Installation](#1-installation)
  - [2. Basic Setup](#2-basic-setup)
  - [3. First Event](#3-first-event)
- [📈 Event Tracking](#-event-tracking)
  - [Standard Events](#standard-events)
  - [Custom Events](#custom-events)
- [👤 User Properties](#-user-properties)
  - [Setting User Properties](#setting-user-properties)
  - [User Property Best Practices](#user-property-best-practices)
- [📱 Screen Tracking](#-screen-tracking)
  - [Automatic Screen Tracking](#automatic-screen-tracking)
  - [Screen Tracking Integration](#screen-tracking-integration)
- [💰 E-commerce Tracking](#-e-commerce-tracking)
  - [Purchase Events](#purchase-events)
  - [Product Views](#product-views)
- [🎮 Gaming Analytics](#-gaming-analytics)
  - [Game Events](#game-events)
- [🚨 Error Tracking](#-error-tracking)
  - [Application Errors](#application-errors)
- [🔧 Configuration](#-configuration)
  - [Advanced Configuration](#advanced-configuration)
  - [Privacy Configuration](#privacy-configuration)
- [📊 Performance Monitoring](#-performance-monitoring)
  - [App Performance](#app-performance)
- [🎯 Best Practices](#-best-practices)
  - [Event Naming](#event-naming)
  - [Parameter Guidelines](#parameter-guidelines)
  - [Performance Considerations](#performance-considerations)
  - [Privacy Compliance](#privacy-compliance)
- [🔗 Related Documentation](#-related-documentation)
- [📞 Support](#-support)
<!-- TOC END -->


## 📊 Firebase Analytics Integration Guide

Complete guide for integrating Firebase Analytics into your iOS application.

---

## 🚀 Quick Start

### 1. Installation

Add Firebase Analytics to your project:

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

// Initialize analytics manager
let analyticsManager = FirebaseAnalyticsManager.shared

// Configure analytics
let config = AnalyticsConfiguration()
config.enableUserProperties = true
config.enableCustomEvents = true
config.enableConversionTracking = true

analyticsManager.configure(config) { result in
    switch result {
    case .success:
        print("✅ Analytics configured successfully")
    case .failure(let error):
        print("❌ Analytics configuration failed: \(error)")
    }
}
```

### 3. First Event

```swift
// Log your first event
analyticsManager.logEvent("app_opened") { result in
    switch result {
    case .success:
        print("✅ App opened event logged")
    case .failure(let error):
        print("❌ Event logging failed: \(error)")
    }
}
```

---

## 📈 Event Tracking

### Standard Events

Firebase Analytics provides several standard events you can track:

```swift
// App lifecycle events
analyticsManager.logEvent("app_open")
analyticsManager.logEvent("app_close")

// User engagement events
analyticsManager.logEvent("user_engagement")
analyticsManager.logEvent("screen_view")

// E-commerce events
analyticsManager.logEvent("purchase")
analyticsManager.logEvent("add_to_cart")
analyticsManager.logEvent("view_item")

// Gaming events
analyticsManager.logEvent("level_up")
analyticsManager.logEvent("achievement_unlocked")
```

### Custom Events

Track custom events specific to your application:

```swift
// Feature usage
analyticsManager.logEvent(
    "feature_used",
    parameters: [
        "feature_name": "dark_mode",
        "user_type": "premium",
        "session_duration": 300
    ]
) { result in
    switch result {
    case .success:
        print("✅ Feature usage tracked")
    case .failure(let error):
        print("❌ Feature tracking failed: \(error)")
    }
}

// User actions
analyticsManager.logEvent(
    "button_clicked",
    parameters: [
        "button_id": "save_profile",
        "screen": "profile_edit",
        "user_type": "premium"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Button click tracked")
    case .failure(let error):
        print("❌ Button tracking failed: \(error)")
    }
}
```

---

## 👤 User Properties

### Setting User Properties

Track user characteristics and behaviors:

```swift
// Set user properties
analyticsManager.setUserProperty("premium", value: "true")
analyticsManager.setUserProperty("subscription_type", value: "monthly")
analyticsManager.setUserProperty("user_level", value: "advanced")
analyticsManager.setUserProperty("signup_method", value: "google")

// Set user ID
analyticsManager.setUserID("user_123456") { result in
    switch result {
    case .success:
        print("✅ User ID set")
    case .failure(let error):
        print("❌ User ID failed: \(error)")
    }
}
```

### User Property Best Practices

- Use descriptive property names
- Keep values consistent
- Avoid personal information
- Update properties when user state changes

---

## 📱 Screen Tracking

### Automatic Screen Tracking

Track screen views automatically:

```swift
// Track screen view
analyticsManager.logScreenView(
    screenName: "ProductDetail",
    screenClass: "ProductDetailViewController"
) { result in
    switch result {
    case .success:
        print("✅ Screen view logged")
    case .failure(let error):
        print("❌ Screen view failed: \(error)")
    }
}

// Track with custom parameters
analyticsManager.logScreenView(
    screenName: "UserProfile",
    screenClass: "ProfileViewController",
    parameters: [
        "user_type": "premium",
        "profile_completeness": 85
    ]
) { result in
    switch result {
    case .success:
        print("✅ Profile screen logged")
    case .failure(let error):
        print("❌ Profile screen failed: \(error)")
    }
}
```

### Screen Tracking Integration

Integrate with your view controllers:

```swift
class ProductDetailViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        analyticsManager.logScreenView(
            screenName: "ProductDetail",
            screenClass: "ProductDetailViewController"
        ) { result in
            switch result {
            case .success:
                print("✅ Product detail screen logged")
            case .failure(let error):
                print("❌ Screen logging failed: \(error)")
            }
        }
    }
}
```

---

## 💰 E-commerce Tracking

### Purchase Events

Track purchase events for e-commerce applications:

```swift
// Track purchase
analyticsManager.logEvent(
    "purchase",
    parameters: [
        "transaction_id": "txn_123456",
        "value": 29.99,
        "currency": "USD",
        "items": [
            [
                "item_id": "premium_monthly",
                "item_name": "Premium Monthly",
                "price": 29.99,
                "quantity": 1
            ]
        ]
    ]
) { result in
    switch result {
    case .success:
        print("✅ Purchase tracked")
    case .failure(let error):
        print("❌ Purchase tracking failed: \(error)")
    }
}

// Track add to cart
analyticsManager.logEvent(
    "add_to_cart",
    parameters: [
        "item_id": "product_123",
        "item_name": "Premium Subscription",
        "price": 29.99,
        "currency": "USD",
        "quantity": 1
    ]
) { result in
    switch result {
    case .success:
        print("✅ Add to cart tracked")
    case .failure(let error):
        print("❌ Add to cart failed: \(error)")
    }
}
```

### Product Views

Track product view events:

```swift
// Track product view
analyticsManager.logEvent(
    "view_item",
    parameters: [
        "item_id": "product_123",
        "item_name": "Premium Subscription",
        "item_category": "subscription",
        "price": 29.99,
        "currency": "USD"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Product view tracked")
    case .failure(let error):
        print("❌ Product view failed: \(error)")
    }
}
```

---

## 🎮 Gaming Analytics

### Game Events

Track gaming-specific events:

```swift
// Track level completion
analyticsManager.logEvent(
    "level_complete",
    parameters: [
        "level_id": "level_5",
        "level_name": "Forest Adventure",
        "score": 1500,
        "time_spent": 120,
        "attempts": 3
    ]
) { result in
    switch result {
    case .success:
        print("✅ Level complete tracked")
    case .failure(let error):
        print("❌ Level tracking failed: \(error)")
    }
}

// Track achievement
analyticsManager.logEvent(
    "achievement_unlocked",
    parameters: [
        "achievement_id": "first_win",
        "achievement_name": "First Victory",
        "game_mode": "single_player",
        "difficulty": "normal"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Achievement tracked")
    case .failure(let error):
        print("❌ Achievement failed: \(error)")
    }
}
```

---

## 🚨 Error Tracking

### Application Errors

Track application errors and crashes:

```swift
// Track error
do {
    // Some operation that might fail
    try performRiskyOperation()
} catch {
    analyticsManager.logError(error, context: "data_sync") { result in
        switch result {
        case .success:
            print("✅ Error tracked")
        case .failure(let logError):
            print("❌ Error tracking failed: \(logError)")
        }
    }
}

// Track custom error
let customError = NSError(
    domain: "com.app.analytics",
    code: 1001,
    userInfo: [
        NSLocalizedDescriptionKey: "Network timeout",
        "operation": "user_login",
        "retry_count": 3
    ]
)

analyticsManager.logError(customError, context: "authentication") { result in
    switch result {
    case .success:
        print("✅ Custom error tracked")
    case .failure(let error):
        print("❌ Custom error failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### Advanced Configuration

Configure analytics for different environments:

```swift
// Production configuration
let productionConfig = AnalyticsConfiguration()
productionConfig.enableUserProperties = true
productionConfig.enableCustomEvents = true
productionConfig.enableConversionTracking = true
productionConfig.enableAudienceSegmentation = true
productionConfig.enableDebugMode = false
productionConfig.sessionTimeoutDuration = 1800
productionConfig.minimumSessionDuration = 10

// Development configuration
#if DEBUG
let debugConfig = AnalyticsConfiguration()
debugConfig.enableDebugMode = true
debugConfig.enableAnalyticsCollection = true
debugConfig.sessionTimeoutDuration = 300
debugConfig.minimumSessionDuration = 5
#endif

// Apply configuration
analyticsManager.configure(productionConfig) { result in
    switch result {
    case .success:
        print("✅ Analytics configured")
    case .failure(let error):
        print("❌ Configuration failed: \(error)")
    }
}
```

### Privacy Configuration

Configure analytics for privacy compliance:

```swift
// GDPR compliance
analyticsManager.setUserProperty("gdpr_consent", value: "true")
analyticsManager.setUserProperty("data_collection", value: "explicit")

// CCPA compliance
analyticsManager.setUserProperty("ccpa_consent", value: "true")
analyticsManager.setUserProperty("data_sale_opt_out", value: "false")
```

---

## 📊 Performance Monitoring

### App Performance

Track application performance metrics:

```swift
// Track app performance
analyticsManager.logEvent(
    "app_performance",
    parameters: [
        "load_time": 2.5,
        "memory_usage": 150.5,
        "battery_level": 0.75,
        "network_type": "wifi",
        "device_model": UIDevice.current.model
    ]
) { result in
    switch result {
    case .success:
        print("✅ Performance tracked")
    case .failure(let error):
        print("❌ Performance failed: \(error)")
    }
}

// Track feature performance
analyticsManager.logEvent(
    "feature_performance",
    parameters: [
        "feature": "search",
        "response_time": 0.5,
        "success_rate": 0.95,
        "error_count": 2
    ]
) { result in
    switch result {
    case .success:
        print("✅ Feature performance tracked")
    case .failure(let error):
        print("❌ Feature performance failed: \(error)")
    }
}
```

---

## 🎯 Best Practices

### Event Naming

- Use descriptive, consistent names
- Follow snake_case convention
- Be specific about what you're tracking
- Avoid personal information in names

### Parameter Guidelines

- Keep parameter names short and clear
- Use consistent data types
- Limit to 25 parameters per event
- Avoid sensitive information

### Performance Considerations

- Batch events when possible
- Avoid excessive logging
- Monitor analytics impact
- Use appropriate event frequency

### Privacy Compliance

- Respect user privacy preferences
- Implement proper consent mechanisms
- Follow GDPR and CCPA guidelines
- Provide data deletion options

---

## 🔗 Related Documentation

- [Analytics API](AnalyticsAPI.md)
- [Getting Started Guide](GettingStarted.md)
- [Performance API](PerformanceAPI.md)
- [Configuration API](ConfigurationAPI.md)
- [Integration API](IntegrationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
