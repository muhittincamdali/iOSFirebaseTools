# Cloud Messaging Guide

## 📱 Firebase Cloud Messaging Integration Guide

Complete guide for integrating Firebase Cloud Messaging into your iOS application.

---

## 🚀 Quick Start

### 1. Installation

Add Firebase Cloud Messaging to your project:

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

// Initialize FCM manager
let fcmManager = FirebaseCloudMessagingManager.shared

// Configure FCM
let config = FCMConfiguration()
config.enableNotifications = true
config.enableDataMessages = true
config.enableBackgroundMessages = true
config.enableTopicMessaging = true

fcmManager.configure(config) { result in
    switch result {
    case .success:
        print("✅ FCM configured successfully")
    case .failure(let error):
        print("❌ FCM configuration failed: \(error)")
    }
}
```

### 3. Register for Notifications

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

## 📱 Notification Types

### Push Notifications

Standard push notifications that appear in the notification center:

```swift
// Create push notification
let notification = FCMPushNotification(
    title: "New Message",
    body: "You have a new message from John",
    data: [
        "messageId": "123",
        "sender": "John",
        "timestamp": Date().timeIntervalSince1970
    ]
)

// Send notification
fcmManager.sendNotification(
    notification,
    to: "user-fcm-token"
) { result in
    switch result {
    case .success:
        print("✅ Push notification sent")
    case .failure(let error):
        print("❌ Push notification failed: \(error)")
    }
}
```

### Data Messages

Silent messages that don't show notifications but can trigger app actions:

```swift
// Create data message
let dataMessage = FCMMessage(
    messageID: "data-123",
    title: nil,
    body: nil,
    data: [
        "type": "sync",
        "userId": "user123",
        "timestamp": Date().timeIntervalSince1970
    ],
    isSilent: true
)

// Handle data message
fcmManager.handleMessage(dataMessage) { result in
    switch result {
    case .success:
        print("✅ Data message handled")
    case .failure(let error):
        print("❌ Data message failed: \(error)")
    }
}
```

### Rich Notifications

Notifications with images, videos, and interactive actions:

```swift
// Create rich notification
let richNotification = FCMPushNotification(
    title: "Breaking News",
    body: "Major announcement from our team",
    data: [
        "newsId": "456",
        "category": "breaking",
        "priority": "high"
    ]
)

// Add attachment
richNotification.addAttachment(
    FCMAttachment(
        url: "https://example.com/image.jpg",
        type: "image/jpeg",
        identifier: "news-image"
    )
)

// Add action
richNotification.addAction(
    FCMNotificationAction(
        identifier: "read_more",
        title: "Read More",
        options: [.foreground]
    )
)

// Send rich notification
fcmManager.sendRichNotification(
    richNotification,
    to: "user-fcm-token"
) { result in
    switch result {
    case .success:
        print("✅ Rich notification sent")
    case .failure(let error):
        print("❌ Rich notification failed: \(error)")
    }
}
```

---

## 🔑 Token Management

### Get FCM Token

```swift
// Get current FCM token
fcmManager.getFCMToken { result in
    switch result {
    case .success(let token):
        print("✅ FCM token: \(token)")
        // Send token to your server
    case .failure(let error):
        print("❌ Token retrieval failed: \(error)")
    }
}
```

### Refresh FCM Token

```swift
// Refresh FCM token
fcmManager.refreshFCMToken { result in
    switch result {
    case .success(let token):
        print("✅ FCM token refreshed: \(token)")
        // Update token on your server
    case .failure(let error):
        print("❌ Token refresh failed: \(error)")
    }
}
```

### Delete FCM Token

```swift
// Delete FCM token
fcmManager.deleteFCMToken { result in
    switch result {
    case .success:
        print("✅ FCM token deleted")
    case .failure(let error):
        print("❌ Token deletion failed: \(error)")
    }
}
```

---

## 📢 Topic Management

### Subscribe to Topics

```swift
// Subscribe to single topic
fcmManager.subscribeToTopic("news") { result in
    switch result {
    case .success:
        print("✅ Subscribed to news topic")
    case .failure(let error):
        print("❌ Topic subscription failed: \(error)")
    }
}

// Subscribe to multiple topics
let topics = ["news", "sports", "technology"]
fcmManager.subscribeToTopics(topics) { result in
    switch result {
    case .success:
        print("✅ Subscribed to multiple topics")
    case .failure(let error):
        print("❌ Multiple topic subscription failed: \(error)")
    }
}
```

### Unsubscribe from Topics

```swift
// Unsubscribe from topic
fcmManager.unsubscribeFromTopic("news") { result in
    switch result {
    case .success:
        print("✅ Unsubscribed from news topic")
    case .failure(let error):
        print("❌ Topic unsubscription failed: \(error)")
    }
}
```

### Get Subscribed Topics

```swift
// Get subscribed topics
fcmManager.getSubscribedTopics { result in
    switch result {
    case .success(let topics):
        print("✅ Subscribed topics: \(topics)")
    case .failure(let error):
        print("❌ Topic retrieval failed: \(error)")
    }
}
```

---

## 🔔 Notification Handling

### Foreground Message Handling

```swift
// Handle foreground messages
fcmManager.setForegroundMessageHandler { message in
    print("📱 Foreground message received")
    print("Title: \(message.title)")
    print("Body: \(message.body)")
    print("Data: \(message.data)")
    
    // Handle message based on type
    if let messageId = message.data["messageId"] {
        print("Message ID: \(messageId)")
        // Navigate to message
    }
    
    // Return true to show notification, false to suppress
    return true
}
```

### Background Message Handling

```swift
// Handle background messages
fcmManager.setBackgroundMessageHandler { message in
    print("🔄 Background message received")
    print("Title: \(message.title)")
    print("Body: \(message.body)")
    print("Data: \(message.data)")
    
    // Process background message
    if let messageId = message.data["messageId"] {
        // Update local database
        updateMessageStatus(messageId, status: "received")
    }
    
    // Return true to indicate successful processing
    return true
}
```

### Silent Notification Handling

```swift
// Handle silent notifications
fcmManager.setSilentNotificationHandler { message in
    print("🔇 Silent notification received")
    print("Data: \(message.data)")
    
    // Process silent notification
    if let syncData = message.data["sync"] {
        // Sync data in background
        syncUserData(syncData)
    }
    
    return true
}
```

---

## 🎯 Notification Actions

### Action Configuration

```swift
// Configure notification actions
let actions = [
    FCMNotificationAction(
        identifier: "reply",
        title: "Reply",
        options: [.foreground]
    ),
    FCMNotificationAction(
        identifier: "mark_read",
        title: "Mark as Read",
        options: [.destructive]
    ),
    FCMNotificationAction(
        identifier: "delete",
        title: "Delete",
        options: [.destructive]
    )
]

fcmManager.configureNotificationActions(actions) { result in
    switch result {
    case .success:
        print("✅ Notification actions configured")
    case .failure(let error):
        print("❌ Action configuration failed: \(error)")
    }
}
```

### Action Handling

```swift
// Handle notification actions
fcmManager.setNotificationActionHandler { action in
    print("🔘 Notification action: \(action.identifier)")
    
    switch action.identifier {
    case "reply":
        print("User tapped reply")
        // Handle reply action
        handleReplyAction(action)
        
    case "mark_read":
        print("User tapped mark as read")
        // Handle mark as read action
        handleMarkAsReadAction(action)
        
    case "delete":
        print("User tapped delete")
        // Handle delete action
        handleDeleteAction(action)
        
    default:
        print("Unknown action: \(action.identifier)")
    }
}
```

---

## 📊 Analytics Integration

### Notification Analytics

```swift
// Track notification received
fcmManager.trackNotificationReceived(message) { result in
    switch result {
    case .success:
        print("✅ Notification received tracked")
    case .failure(let error):
        print("❌ Notification tracking failed: \(error)")
    }
}

// Track notification opened
fcmManager.trackNotificationOpened(message) { result in
    switch result {
    case .success:
        print("✅ Notification opened tracked")
    case .failure(let error):
        print("❌ Open tracking failed: \(error)")
    }
}

// Track notification action
fcmManager.trackNotificationAction(action) { result in
    switch result {
    case .success:
        print("✅ Notification action tracked")
    case .failure(let error):
        print("❌ Action tracking failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### FCM Configuration

```swift
// Configure FCM settings
let fcmConfig = FCMConfiguration()

// Enable FCM features
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true
fcmConfig.enableTopicMessaging = true
fcmConfig.enableRichNotifications = true
fcmConfig.enableSilentNotifications = true
fcmConfig.enableNotificationActions = true
fcmConfig.enableBadgeManagement = true
fcmConfig.enableSoundAndVibration = true
fcmConfig.autoInitEnabled = true

// Apply configuration
fcmManager.configure(fcmConfig) { result in
    switch result {
    case .success:
        print("✅ FCM configured")
    case .failure(let error):
        print("❌ FCM configuration failed: \(error)")
    }
}
```

### Notification Settings

```swift
// Configure notification settings
let notificationSettings = FCMNotificationSettings()
notificationSettings.alert = true
notificationSettings.badge = true
notificationSettings.sound = true
notificationSettings.criticalAlert = false
notificationSettings.provisional = false

fcmManager.configureNotificationSettings(notificationSettings) { result in
    switch result {
    case .success:
        print("✅ Notification settings configured")
    case .failure(let error):
        print("❌ Settings configuration failed: \(error)")
    }
}
```

---

## 🚨 Error Handling

### Common Errors

```swift
// Handle common FCM errors
fcmManager.registerForRemoteNotifications { result in
    switch result {
    case .success(let token):
        print("✅ Registration successful: \(token)")
    case .failure(let error):
        switch error {
        case .notificationPermissionDenied:
            print("❌ Notification permission denied")
            // Show settings alert
            showNotificationSettingsAlert()
            
        case .registrationFailed(let underlyingError):
            print("❌ Registration failed: \(underlyingError)")
            // Retry registration
            retryRegistration()
            
        case .networkError:
            print("❌ Network error")
            // Retry when network is available
            
        default:
            print("❌ Unknown error: \(error)")
        }
    }
}
```

### Retry Logic

```swift
// Implement retry logic
func retryRegistration(maxAttempts: Int = 3) {
    var attempts = 0
    
    func attemptRegistration() {
        attempts += 1
        
        fcmManager.registerForRemoteNotifications { result in
            switch result {
            case .success(let token):
                print("✅ Registration successful on attempt \(attempts)")
            case .failure(let error):
                if attempts < maxAttempts {
                    print("❌ Attempt \(attempts) failed, retrying...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        attemptRegistration()
                    }
                } else {
                    print("❌ All \(maxAttempts) attempts failed")
                }
            }
        }
    }
    
    attemptRegistration()
}
```

---

## 📱 Best Practices

### Notification Design

- Keep titles short and descriptive
- Use clear, actionable body text
- Include relevant data for app processing
- Test notifications on different devices
- Consider user preferences and settings

### Performance Optimization

- Batch notification operations when possible
- Use silent notifications for background sync
- Implement proper error handling and retry logic
- Monitor notification delivery rates
- Optimize notification payload size

### User Experience

- Request notification permissions at appropriate times
- Provide clear explanations for permission requests
- Allow users to customize notification preferences
- Implement notification grouping for better UX
- Handle notification taps appropriately

---

## 🔗 Related Documentation

- [Cloud Messaging API](CloudMessagingAPI.md)
- [Getting Started Guide](GettingStarted.md)
- [Analytics Guide](AnalyticsGuide.md)
- [Performance API](PerformanceAPI.md)
- [Configuration API](ConfigurationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
