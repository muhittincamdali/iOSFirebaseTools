# Cloud Messaging API

## 📱 Firebase Cloud Messaging API Reference

Comprehensive API documentation for Firebase Cloud Messaging integration in iOS applications.

---

## 🔧 Core Messaging Manager

### FirebaseCloudMessagingManager

The main messaging manager class that handles all Firebase Cloud Messaging operations.

```swift
public class FirebaseCloudMessagingManager {
    public static let shared = FirebaseCloudMessagingManager()
    
    private init() {}
    
    // Configuration methods
    public func configure(_ config: FCMConfiguration)
    public func registerForRemoteNotifications()
    public func unregisterFromRemoteNotifications()
    
    // Token management
    public func getFCMToken()
    public func refreshFCMToken()
    public func deleteFCMToken()
    
    // Topic management
    public func subscribeToTopic(_ topic: String)
    public func unsubscribeFromTopic(_ topic: String)
    
    // Message handling
    public func sendNotification(_ notification: FCMPushNotification, to token: String)
    public func sendNotificationToTopic(_ notification: FCMPushNotification, topic: String)
    
    // Background message handling
    public func handleBackgroundMessage(_ message: FCMMessage)
    public func setBackgroundMessageHandler(_ handler: @escaping (FCMMessage) -> Void)
}
```

### FCMConfiguration

Configuration class for Firebase Cloud Messaging settings.

```swift
public struct FCMConfiguration {
    public var enableNotifications: Bool = true
    public var enableDataMessages: Bool = true
    public var enableBackgroundMessages: Bool = true
    public var enableTopicMessaging: Bool = true
    public var enableRichNotifications: Bool = true
    public var enableSilentNotifications: Bool = true
    public var enableNotificationActions: Bool = true
    public var enableBadgeManagement: Bool = true
    public var enableSoundAndVibration: Bool = true
    public var autoInitEnabled: Bool = true
}
```

---

## 📱 Notification Registration

### Register for Remote Notifications

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

// Unregister from remote notifications
fcmManager.unregisterFromRemoteNotifications { result in
    switch result {
    case .success:
        print("✅ Unregistered from remote notifications")
    case .failure(let error):
        print("❌ Unregistration failed: \(error)")
    }
}

// Check notification authorization status
fcmManager.getNotificationAuthorizationStatus { result in
    switch result {
    case .success(let status):
        print("✅ Notification status: \(status)")
    case .failure(let error):
        print("❌ Status check failed: \(error)")
    }
}
```

### Request Notification Permission

```swift
// Request notification permission
fcmManager.requestNotificationPermission { result in
    switch result {
    case .success(let granted):
        if granted {
            print("✅ Notification permission granted")
        } else {
            print("❌ Notification permission denied")
        }
    case .failure(let error):
        print("❌ Permission request failed: \(error)")
    }
}

// Request notification permission with options
let options = NotificationPermissionOptions()
options.alert = true
options.badge = true
options.sound = true
options.criticalAlert = false
options.provisional = false

fcmManager.requestNotificationPermission(options: options) { result in
    switch result {
    case .success(let granted):
        print("✅ Permission request completed: \(granted)")
    case .failure(let error):
        print("❌ Permission request failed: \(error)")
    }
}
```

---

## 🔑 Token Management

### FCM Token Operations

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

// Delete FCM token
fcmManager.deleteFCMToken { result in
    switch result {
    case .success:
        print("✅ FCM token deleted")
    case .failure(let error):
        print("❌ Token deletion failed: \(error)")
    }
}

// Listen for token refresh
fcmManager.addTokenRefreshListener { token in
    print("🔄 FCM token refreshed: \(token)")
    // Update token on your server
}
```

### Token Validation

```swift
// Validate FCM token
fcmManager.validateFCMToken("your-fcm-token") { result in
    switch result {
    case .success(let isValid):
        if isValid {
            print("✅ FCM token is valid")
        } else {
            print("❌ FCM token is invalid")
        }
    case .failure(let error):
        print("❌ Token validation failed: \(error)")
    }
}

// Get token info
fcmManager.getTokenInfo("your-fcm-token") { result in
    switch result {
    case .success(let info):
        print("✅ Token info: \(info)")
    case .failure(let error):
        print("❌ Token info failed: \(error)")
    }
}
```

---

## 📢 Topic Management

### Topic Subscription

```swift
// Subscribe to topic
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

// Unsubscribe from topic
fcmManager.unsubscribeFromTopic("news") { result in
    switch result {
    case .success:
        print("✅ Unsubscribed from news topic")
    case .failure(let error):
        print("❌ Topic unsubscription failed: \(error)")
    }
}

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

### Topic Validation

```swift
// Validate topic name
fcmManager.validateTopicName("news") { result in
    switch result {
    case .success(let isValid):
        if isValid {
            print("✅ Topic name is valid")
        } else {
            print("❌ Topic name is invalid")
        }
    case .failure(let error):
        print("❌ Topic validation failed: \(error)")
    }
}

// Check topic subscription status
fcmManager.isSubscribedToTopic("news") { result in
    switch result {
    case .success(let isSubscribed):
        if isSubscribed {
            print("✅ Subscribed to news topic")
        } else {
            print("❌ Not subscribed to news topic")
        }
    case .failure(let error):
        print("❌ Subscription check failed: \(error)")
    }
}
```

---

## 📨 Message Sending

### Send Push Notifications

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

// Send to specific token
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

// Send to topic
fcmManager.sendNotificationToTopic(
    notification,
    topic: "news"
) { result in
    switch result {
    case .success:
        print("✅ Topic notification sent")
    case .failure(let error):
        print("❌ Topic notification failed: \(error)")
    }
}

// Send to multiple tokens
let tokens = ["token1", "token2", "token3"]
fcmManager.sendNotificationToTokens(
    notification,
    tokens: tokens
) { result in
    switch result {
    case .success:
        print("✅ Multi-token notification sent")
    case .failure(let error):
        print("❌ Multi-token notification failed: \(error)")
    }
}
```

### Rich Notifications

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

// Add rich content
richNotification.addAttachment(
    url: "https://example.com/image.jpg",
    type: "image/jpeg"
)

richNotification.addAction(
    identifier: "read_more",
    title: "Read More",
    options: [.foreground]
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

// Handle notification tap
fcmManager.setNotificationTapHandler { message in
    print("👆 Notification tapped")
    print("Title: \(message.title)")
    print("Body: \(message.body)")
    print("Data: \(message.data)")
    
    // Handle notification tap
    if let messageId = message.data["messageId"] {
        // Navigate to message detail
        navigateToMessage(messageId)
    }
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

// Handle custom actions
fcmManager.setCustomActionHandler { action in
    print("🎯 Custom action: \(action.identifier)")
    print("Action data: \(action.data)")
    
    // Handle custom action
    handleCustomAction(action)
}
```

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

## 🔗 Related Documentation

- [Cloud Messaging Guide](CloudMessagingGuide.md)
- [Getting Started Guide](GettingStarted.md)
- [Analytics API](AnalyticsAPI.md)
- [Configuration API](ConfigurationAPI.md)
- [Integration API](IntegrationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
