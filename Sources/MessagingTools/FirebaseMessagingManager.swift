import Foundation
import FirebaseMessaging
import UserNotifications

/// Firebase Cloud Messaging Manager for handling push notifications and messaging
public class FirebaseMessagingManager {
    
    // MARK: - Singleton
    public static let shared = FirebaseMessagingManager()
    private init() {}
    
    // MARK: - Properties
    private var isConfigured = false
    private var messageHandlers: [String: (FCMMessage) -> Void] = [:]
    private var notificationHandlers: [String: (FCMPushNotification) -> Void] = [:]
    
    // MARK: - Configuration
    public struct MessagingConfiguration {
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
        
        public init() {}
    }
    
    // MARK: - Data Models
    public struct FCMMessage {
        public let messageID: String
        public let title: String?
        public let body: String?
        public let data: [String: Any]
        public let timestamp: Date
        public let isSilent: Bool
        
        public init(messageID: String, title: String?, body: String?, data: [String: Any], timestamp: Date = Date(), isSilent: Bool = false) {
            self.messageID = messageID
            self.title = title
            self.body = body
            self.data = data
            self.timestamp = timestamp
            self.isSilent = isSilent
        }
    }
    
    public struct FCMPushNotification {
        public let title: String
        public let body: String
        public let data: [String: Any]
        public let badge: Int?
        public let sound: String?
        public let category: String?
        public let attachments: [FCMAttachment]
        public let actions: [FCMNotificationAction]
        
        public init(title: String, body: String, data: [String: Any] = [:], badge: Int? = nil, sound: String? = nil, category: String? = nil, attachments: [FCMAttachment] = [], actions: [FCMNotificationAction] = []) {
            self.title = title
            self.body = body
            self.data = data
            self.badge = badge
            self.sound = sound
            self.category = category
            self.attachments = attachments
            self.actions = actions
        }
        
        public mutating func addAttachment(_ attachment: FCMAttachment) {
            var newAttachments = attachments
            newAttachments.append(attachment)
            self.attachments = newAttachments
        }
        
        public mutating func addAction(_ action: FCMNotificationAction) {
            var newActions = actions
            newActions.append(action)
            self.actions = newActions
        }
    }
    
    public struct FCMAttachment {
        public let url: String
        public let type: String
        public let identifier: String
        
        public init(url: String, type: String, identifier: String) {
            self.url = url
            self.type = type
            self.identifier = identifier
        }
    }
    
    public struct FCMNotificationAction {
        public let identifier: String
        public let title: String
        public let options: UNNotificationActionOptions
        
        public init(identifier: String, title: String, options: UNNotificationActionOptions = []) {
            self.identifier = identifier
            self.title = title
            self.options = options
        }
    }
    
    // MARK: - Error Types
    public enum MessagingError: Error, LocalizedError {
        case configurationFailed
        case registrationFailed(Error)
        case tokenRetrievalFailed(Error)
        case topicSubscriptionFailed(Error)
        case messageSendingFailed(Error)
        case notificationPermissionDenied
        case invalidMessage
        case networkError
        case notConfigured
        
        public var errorDescription: String? {
            switch self {
            case .configurationFailed:
                return "Messaging configuration failed"
            case .registrationFailed(let error):
                return "Registration failed: \(error.localizedDescription)"
            case .tokenRetrievalFailed(let error):
                return "Token retrieval failed: \(error.localizedDescription)"
            case .topicSubscriptionFailed(let error):
                return "Topic subscription failed: \(error.localizedDescription)"
            case .messageSendingFailed(let error):
                return "Message sending failed: \(error.localizedDescription)"
            case .notificationPermissionDenied:
                return "Notification permission denied"
            case .invalidMessage:
                return "Invalid message format"
            case .networkError:
                return "Network connection error"
            case .notConfigured:
                return "Messaging manager not configured"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Configure the messaging manager
    /// - Parameters:
    ///   - config: Messaging configuration
    ///   - completion: Completion handler
    public func configure(_ config: MessagingConfiguration, completion: @escaping (Result<Void, MessagingError>) -> Void) {
        guard !isConfigured else {
            completion(.failure(.configurationFailed))
            return
        }
        
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Configure auto initialization
        Messaging.messaging().isAutoInitEnabled = config.autoInitEnabled
        
        // Configure notification settings
        if config.enableNotifications {
            configureNotificationSettings { result in
                switch result {
                case .success:
                    print("✅ Notification settings configured")
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
        
        isConfigured = true
        completion(.success(()))
    }
    
    /// Register for remote notifications
    /// - Parameter completion: Completion handler
    public func registerForRemoteNotifications(completion: @escaping (Result<String, MessagingError>) -> Void) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                completion(.failure(.registrationFailed(error)))
                return
            }
            
            if !granted {
                completion(.failure(.notificationPermissionDenied))
                return
            }
            
            // Register for remote notifications
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
            // Get FCM token
            Messaging.messaging().token { token, error in
                if let error = error {
                    completion(.failure(.tokenRetrievalFailed(error)))
                } else if let token = token {
                    completion(.success(token))
                } else {
                    completion(.failure(.tokenRetrievalFailed(NSError(domain: "Messaging", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))))
                }
            }
        }
    }
    
    /// Get current FCM token
    /// - Parameter completion: Completion handler
    public func getFCMToken(completion: @escaping (Result<String, MessagingError>) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                completion(.failure(.tokenRetrievalFailed(error)))
            } else if let token = token {
                completion(.success(token))
            } else {
                completion(.failure(.tokenRetrievalFailed(NSError(domain: "Messaging", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))))
            }
        }
    }
    
    /// Subscribe to topic
    /// - Parameters:
    ///   - topic: Topic name
    ///   - completion: Completion handler
    public func subscribeToTopic(_ topic: String, completion: @escaping (Result<Void, MessagingError>) -> Void) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                completion(.failure(.topicSubscriptionFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Unsubscribe from topic
    /// - Parameters:
    ///   - topic: Topic name
    ///   - completion: Completion handler
    public func unsubscribeFromTopic(_ topic: String, completion: @escaping (Result<Void, MessagingError>) -> Void) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                completion(.failure(.topicSubscriptionFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Send notification to specific token
    /// - Parameters:
    ///   - notification: Push notification
    ///   - token: FCM token
    ///   - completion: Completion handler
    public func sendNotification(
        _ notification: FCMPushNotification,
        to token: String,
        completion: @escaping (Result<Void, MessagingError>) -> Void
    ) {
        // This would typically be done through your backend server
        // For client-side, we can only send local notifications
        scheduleLocalNotification(notification) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Send notification to topic
    /// - Parameters:
    ///   - notification: Push notification
    ///   - topic: Topic name
    ///   - completion: Completion handler
    public func sendNotificationToTopic(
        _ notification: FCMPushNotification,
        topic: String,
        completion: @escaping (Result<Void, MessagingError>) -> Void
    ) {
        // This would typically be done through your backend server
        // For client-side, we can only send local notifications
        scheduleLocalNotification(notification) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Handle incoming message
    /// - Parameters:
    ///   - message: FCM message
    ///   - completion: Completion handler
    public func handleMessage(_ message: FCMMessage, completion: @escaping (Result<Void, MessagingError>) -> Void) {
        // Process message based on type
        if message.isSilent {
            handleSilentMessage(message)
        } else {
            handleNotificationMessage(message)
        }
        
        completion(.success(()))
    }
    
    /// Set message handler for specific message type
    /// - Parameters:
    ///   - type: Message type
    ///   - handler: Message handler
    public func setMessageHandler(for type: String, handler: @escaping (FCMMessage) -> Void) {
        messageHandlers[type] = handler
    }
    
    /// Set notification handler for specific notification type
    /// - Parameters:
    ///   - type: Notification type
    ///   - handler: Notification handler
    public func setNotificationHandler(for type: String, handler: @escaping (FCMPushNotification) -> Void) {
        notificationHandlers[type] = handler
    }
    
    /// Schedule local notification
    /// - Parameters:
    ///   - notification: Push notification
    ///   - completion: Completion handler
    public func scheduleLocalNotification(
        _ notification: FCMPushNotification,
        completion: @escaping (Result<Void, MessagingError>) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.userInfo = notification.data
        
        if let badge = notification.badge {
            content.badge = NSNumber(value: badge)
        }
        
        if let sound = notification.sound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
        } else {
            content.sound = UNNotificationSound.default
        }
        
        if let category = notification.category {
            content.categoryIdentifier = category
        }
        
        // Add attachments
        for attachment in notification.attachments {
            if let url = URL(string: attachment.url) {
                do {
                    let attachment = try UNNotificationAttachment(identifier: attachment.identifier, url: url, options: [UNNotificationAttachmentOptionsTypeHintKey: attachment.type])
                    content.attachments.append(attachment)
                } catch {
                    print("Failed to create notification attachment: \(error)")
                }
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                completion(.failure(.messageSendingFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Get notification authorization status
    /// - Parameter completion: Completion handler
    public func getNotificationAuthorizationStatus(completion: @escaping (Result<UNAuthorizationStatus, MessagingError>) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(.success(settings.authorizationStatus))
        }
    }
    
    /// Clear all notifications
    /// - Parameter completion: Completion handler
    public func clearAllNotifications(completion: @escaping (Result<Void, MessagingError>) -> Void) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completion(.success(()))
    }
    
    /// Set badge count
    /// - Parameters:
    ///   - count: Badge count
    ///   - completion: Completion handler
    public func setBadgeCount(_ count: Int, completion: @escaping (Result<Void, MessagingError>) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
            completion(.success(()))
        }
    }
    
    // MARK: - Private Methods
    
    private func configureNotificationSettings(completion: @escaping (Result<Void, MessagingError>) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        // Create notification categories
        let categories = createNotificationCategories()
        center.setNotificationCategories(categories)
        
        completion(.success(()))
    }
    
    private func createNotificationCategories() -> Set<UNNotificationCategory> {
        var categories: Set<UNNotificationCategory> = []
        
        // Message category
        let replyAction = UNTextInputNotificationAction(
            identifier: "reply",
            title: "Reply",
            options: [.foreground]
        )
        
        let markAsReadAction = UNNotificationAction(
            identifier: "mark_read",
            title: "Mark as Read",
            options: [.destructive]
        )
        
        let messageCategory = UNNotificationCategory(
            identifier: "message",
            actions: [replyAction, markAsReadAction],
            intentIdentifiers: [],
            options: []
        )
        
        categories.insert(messageCategory)
        
        return categories
    }
    
    private func handleSilentMessage(_ message: FCMMessage) {
        // Handle silent message (data message)
        if let messageType = message.data["type"] as? String,
           let handler = messageHandlers[messageType] {
            handler(message)
        }
    }
    
    private func handleNotificationMessage(_ message: FCMMessage) {
        // Handle notification message
        let notification = FCMPushNotification(
            title: message.title ?? "Notification",
            body: message.body ?? "",
            data: message.data
        )
        
        if let messageType = message.data["type"] as? String,
           let handler = notificationHandlers[messageType] {
            handler(notification)
        }
    }
}

// MARK: - MessagingDelegate

extension FirebaseMessagingManager: MessagingDelegate {
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "nil")")
        
        // Send token to your server
        if let token = fcmToken {
            sendTokenToServer(token)
        }
    }
    
    private func sendTokenToServer(_ token: String) {
        // Implement token sending to your server
        print("Sending FCM token to server: \(token)")
    }
}

// MARK: - Extensions

extension FirebaseMessagingManager {
    
    /// Check if messaging is properly configured
    /// - Returns: Configuration status
    public func isMessagingConfigured() -> Bool {
        return isConfigured
    }
    
    /// Refresh FCM token
    /// - Parameter completion: Completion handler
    public func refreshFCMToken(completion: @escaping (Result<String, MessagingError>) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                completion(.failure(.tokenRetrievalFailed(error)))
            } else if let token = token {
                completion(.success(token))
            } else {
                completion(.failure(.tokenRetrievalFailed(NSError(domain: "Messaging", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))))
            }
        }
    }
    
    /// Delete FCM token
    /// - Parameter completion: Completion handler
    public func deleteFCMToken(completion: @escaping (Result<Void, MessagingError>) -> Void) {
        Messaging.messaging().deleteToken { error in
            if let error = error {
                completion(.failure(.tokenRetrievalFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Get subscribed topics
    /// - Parameter completion: Completion handler
    public func getSubscribedTopics(completion: @escaping (Result<[String], MessagingError>) -> Void) {
        // This would require additional implementation to track subscribed topics
        // For now, return empty array
        completion(.success([]))
    }
}
