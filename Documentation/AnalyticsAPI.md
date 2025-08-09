# Analytics API

<!-- TOC START -->
## Table of Contents
- [Analytics API](#analytics-api)
- [📊 Firebase Analytics API Reference](#-firebase-analytics-api-reference)
- [🔧 Core Analytics Manager](#-core-analytics-manager)
  - [FirebaseAnalyticsManager](#firebaseanalyticsmanager)
  - [AnalyticsConfiguration](#analyticsconfiguration)
- [📈 Event Logging](#-event-logging)
  - [Basic Event Logging](#basic-event-logging)
  - [Screen View Tracking](#screen-view-tracking)
  - [Purchase Tracking](#purchase-tracking)
- [👤 User Properties](#-user-properties)
  - [Setting User Properties](#setting-user-properties)
  - [User Property Management](#user-property-management)
- [🎯 Custom Events](#-custom-events)
  - [AnalyticsEvent Structure](#analyticsevent-structure)
  - [Custom Event Logging](#custom-event-logging)
- [🚨 Error Tracking](#-error-tracking)
  - [Error Logging](#error-logging)
- [📊 Performance Analytics](#-performance-analytics)
  - [Performance Event Tracking](#performance-event-tracking)
- [🔧 Configuration](#-configuration)
  - [Analytics Setup](#analytics-setup)
  - [Debug Mode](#debug-mode)
- [📈 Best Practices](#-best-practices)
  - [Event Naming Conventions](#event-naming-conventions)
  - [Parameter Guidelines](#parameter-guidelines)
  - [Performance Considerations](#performance-considerations)
- [🔗 Related Documentation](#-related-documentation)
- [📞 Support](#-support)
<!-- TOC END -->


## 📊 Firebase Analytics API Reference

Comprehensive API documentation for Firebase Analytics integration in iOS applications.

---

## 🔧 Core Analytics Manager

### FirebaseAnalyticsManager

The main analytics manager class that handles all Firebase Analytics operations.

```swift
public class FirebaseAnalyticsManager {
    public static let shared = FirebaseAnalyticsManager()
    
    private init() {}
    
    // Configuration methods
    public func configure(_ config: AnalyticsConfiguration)
    public func setUserProperty(_ name: String, value: String?)
    public func setUserID(_ userID: String?)
    
    // Event logging methods
    public func logEvent(_ name: String, parameters: [String: Any]?)
    public func logScreenView(screenName: String, screenClass: String?)
    public func logPurchase(price: Double, currency: String, itemID: String?)
    
    // Custom event methods
    public func logCustomEvent(_ event: AnalyticsEvent)
    public func logUserAction(_ action: String, parameters: [String: Any]?)
    public func logError(_ error: Error, context: String?)
}
```

### AnalyticsConfiguration

Configuration class for Firebase Analytics settings.

```swift
public struct AnalyticsConfiguration {
    public var enableUserProperties: Bool = true
    public var enableCustomEvents: Bool = true
    public var enableConversionTracking: Bool = true
    public var enableAudienceSegmentation: Bool = true
    public var enableDebugMode: Bool = false
    public var enableAnalyticsCollection: Bool = true
    public var sessionTimeoutDuration: TimeInterval = 1800
    public var minimumSessionDuration: TimeInterval = 10
}
```

---

## 📈 Event Logging

### Basic Event Logging

```swift
// Log a simple event
analyticsManager.logEvent("button_click") { result in
    switch result {
    case .success:
        print("✅ Event logged successfully")
    case .failure(let error):
        print("❌ Event logging failed: \(error)")
    }
}

// Log event with parameters
analyticsManager.logEvent(
    "purchase_completed",
    parameters: [
        "item_id": "product_123",
        "price": 29.99,
        "currency": "USD",
        "category": "premium"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Purchase event logged")
    case .failure(let error):
        print("❌ Purchase event failed: \(error)")
    }
}
```

### Screen View Tracking

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

// Track screen view with custom parameters
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

### Purchase Tracking

```swift
// Log purchase event
analyticsManager.logPurchase(
    price: 29.99,
    currency: "USD",
    itemID: "premium_subscription"
) { result in
    switch result {
    case .success:
        print("✅ Purchase logged")
    case .failure(let error):
        print("❌ Purchase failed: \(error)")
    }
}

// Log purchase with additional parameters
analyticsManager.logEvent(
    "purchase_completed",
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
        print("✅ Detailed purchase logged")
    case .failure(let error):
        print("❌ Detailed purchase failed: \(error)")
    }
}
```

---

## 👤 User Properties

### Setting User Properties

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

### User Property Management

```swift
// Clear user property
analyticsManager.setUserProperty("premium", value: nil)

// Update multiple properties
let userProperties = [
    "premium": "true",
    "subscription_type": "monthly",
    "user_level": "advanced",
    "last_login": Date().timeIntervalSince1970
]

for (key, value) in userProperties {
    analyticsManager.setUserProperty(key, value: String(describing: value))
}
```

---

## 🎯 Custom Events

### AnalyticsEvent Structure

```swift
public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: Any]
    public let timestamp: Date
    
    public init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}
```

### Custom Event Logging

```swift
// Create custom event
let customEvent = AnalyticsEvent(
    name: "feature_used",
    parameters: [
        "feature_name": "dark_mode",
        "user_type": "premium",
        "session_duration": 300
    ]
)

// Log custom event
analyticsManager.logCustomEvent(customEvent) { result in
    switch result {
    case .success:
        print("✅ Custom event logged")
    case .failure(let error):
        print("❌ Custom event failed: \(error)")
    }
}

// Log user action
analyticsManager.logUserAction(
    "button_tap",
    parameters: [
        "button_id": "save_profile",
        "screen": "profile_edit",
        "user_type": "premium"
    ]
) { result in
    switch result {
    case .success:
        print("✅ User action logged")
    case .failure(let error):
        print("❌ User action failed: \(error)")
    }
}
```

---

## 🚨 Error Tracking

### Error Logging

```swift
// Log application error
do {
    // Some operation that might fail
    try performRiskyOperation()
} catch {
    analyticsManager.logError(error, context: "data_sync") { result in
        switch result {
        case .success:
            print("✅ Error logged")
        case .failure(let logError):
            print("❌ Error logging failed: \(logError)")
        }
    }
}

// Log custom error
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
        print("✅ Custom error logged")
    case .failure(let error):
        print("❌ Custom error failed: \(error)")
    }
}
```

---

## 📊 Performance Analytics

### Performance Event Tracking

```swift
// Track app performance
analyticsManager.logEvent(
    "app_performance",
    parameters: [
        "load_time": 2.5,
        "memory_usage": 150.5,
        "battery_level": 0.75,
        "network_type": "wifi"
    ]
) { result in
    switch result {
    case .success:
        print("✅ Performance logged")
    case .failure(let error):
        print("❌ Performance failed: \(error)")
    }
}

// Track feature usage
analyticsManager.logEvent(
    "feature_usage",
    parameters: [
        "feature": "search",
        "usage_count": 5,
        "session_duration": 1800,
        "user_satisfaction": 4.5
    ]
) { result in
    switch result {
    case .success:
        print("✅ Feature usage logged")
    case .failure(let error):
        print("❌ Feature usage failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### Analytics Setup

```swift
// Configure analytics
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableUserProperties = true
analyticsConfig.enableCustomEvents = true
analyticsConfig.enableConversionTracking = true
analyticsConfig.enableAudienceSegmentation = true
analyticsConfig.enableDebugMode = false
analyticsConfig.sessionTimeoutDuration = 1800
analyticsConfig.minimumSessionDuration = 10

// Apply configuration
analyticsManager.configure(analyticsConfig) { result in
    switch result {
    case .success:
        print("✅ Analytics configured")
    case .failure(let error):
        print("❌ Analytics configuration failed: \(error)")
    }
}
```

### Debug Mode

```swift
// Enable debug mode for development
#if DEBUG
let debugConfig = AnalyticsConfiguration()
debugConfig.enableDebugMode = true
debugConfig.enableAnalyticsCollection = true

analyticsManager.configure(debugConfig) { result in
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

## 📈 Best Practices

### Event Naming Conventions

- Use snake_case for event names
- Be descriptive and specific
- Use consistent naming patterns
- Avoid personal information in event names

### Parameter Guidelines

- Keep parameter names short and clear
- Use consistent data types
- Avoid sensitive information
- Limit parameter count to 25 per event

### Performance Considerations

- Batch events when possible
- Avoid excessive event logging
- Use appropriate event frequency
- Monitor analytics impact on app performance

---

## 🔗 Related Documentation

- [Getting Started Guide](GettingStarted.md)
- [Analytics Guide](AnalyticsGuide.md)
- [Performance API](PerformanceAPI.md)
- [Configuration API](ConfigurationAPI.md)
- [Integration API](IntegrationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
