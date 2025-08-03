import Foundation
import FirebaseAnalytics
import Combine

// MARK: - Firebase Analytics Manager
/// Advanced Firebase Analytics manager with custom event tracking and performance monitoring.
///
/// This class provides comprehensive analytics capabilities including custom events,
/// user properties, screen tracking, and performance monitoring. It follows Firebase
/// best practices and provides a clean, type-safe API for analytics operations.
///
/// ## Features
/// - Custom event tracking with parameters
/// - User property management
/// - Screen tracking automation
/// - Performance monitoring
/// - Conversion tracking
/// - Revenue tracking
/// - Error tracking
///
/// ## Usage Example
/// ```swift
/// let analytics = FirebaseAnalyticsManager.shared
/// 
/// // Track custom event
/// analytics.trackEvent(
///     name: "purchase_completed",
///     parameters: [
///         "product_id": "123",
///         "price": 99.99,
///         "currency": "USD"
///     ]
/// )
/// 
/// // Set user property
/// analytics.setUserProperty(key: "subscription_type", value: "premium")
/// ```
///
/// - Author: Muhittin Camdali
/// - Since: 1.0.0
/// - Version: 2.1.0
public class FirebaseAnalyticsManager: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = FirebaseAnalyticsManager()
    
    // MARK: - Published Properties
    @Published public var isAnalyticsEnabled = true
    @Published public var currentScreen: String?
    @Published public var sessionStartTime: Date?
    
    // MARK: - Private Properties
    private let analytics = Analytics.self
    private var screenTrackingTimer: Timer?
    private var performanceMetrics: [String: TimeInterval] = [:]
    
    // MARK: - Initialization
    private init() {
        setupAnalytics()
        startSessionTracking()
    }
    
    deinit {
        stopScreenTracking()
    }
    
    // MARK: - Public Methods
    
    /// Initialize Firebase Analytics with custom configuration
    public func initialize(configuration: AnalyticsConfiguration? = nil) {
        if let config = configuration {
            analytics.setAnalyticsCollectionEnabled(config.isEnabled)
        }
        setupAnalytics()
    }
    
    /// Track a custom analytics event with parameters
    /// - Parameters:
    ///   - name: The name of the event to track
    ///   - parameters: Optional parameters to include with the event
    ///   - timestamp: Optional timestamp for the event (defaults to current time)
    public func trackEvent(
        name: String,
        parameters: [String: Any]? = nil,
        timestamp: Date = Date()
    ) {
        guard isAnalyticsEnabled else { return }
        
        do {
            let eventName = AnalyticsEventCustom(name: name)
            analytics.logEvent(eventName, parameters: parameters)
            
            // Log for debugging
            print("📊 Analytics Event: \(name)")
            if let params = parameters {
                print("📊 Parameters: \(params)")
            }
        } catch {
            print("❌ Analytics Error: \(error.localizedDescription)")
        }
    }
    
    /// Set a user property for analytics
    /// - Parameters:
    ///   - key: The property key
    ///   - value: The property value
    public func setUserProperty(key: String, value: String?) {
        guard isAnalyticsEnabled else { return }
        
        analytics.setUserProperty(value, forName: key)
        print("📊 User Property Set: \(key) = \(value ?? "nil")")
    }
    
    /// Track screen view with automatic timing
    /// - Parameters:
    ///   - screenName: The name of the screen
    ///   - screenClass: The class of the screen (optional)
    public func trackScreen(
        screenName: String,
        screenClass: String? = nil
    ) {
        guard isAnalyticsEnabled else { return }
        
        // Stop previous screen tracking
        stopScreenTracking()
        
        // Start new screen tracking
        currentScreen = screenName
        sessionStartTime = Date()
        
        // Log screen view
        analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? "Unknown"
        ])
        
        print("📊 Screen View: \(screenName)")
        
        // Start timer for screen duration tracking
        startScreenTrackingTimer(screenName: screenName)
    }
    
    /// Track user engagement with content
    /// - Parameters:
    ///   - contentType: The type of content
    ///   - contentId: The unique identifier for the content
    ///   - engagementTime: Time spent engaging with content
    public func trackEngagement(
        contentType: String,
        contentId: String,
        engagementTime: TimeInterval
    ) {
        trackEvent(
            name: "user_engagement",
            parameters: [
                "content_type": contentType,
                "content_id": contentId,
                "engagement_time": engagementTime
            ]
        )
    }
    
    /// Track conversion events
    /// - Parameters:
    ///   - conversionType: The type of conversion
    ///   - value: The conversion value
    ///   - currency: The currency code (defaults to USD)
    public func trackConversion(
        conversionType: String,
        value: Double,
        currency: String = "USD"
    ) {
        trackEvent(
            name: "conversion",
            parameters: [
                "conversion_type": conversionType,
                "value": value,
                "currency": currency
            ]
        )
    }
    
    /// Track revenue events
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - price: The product price
    ///   - currency: The currency code
    ///   - quantity: The quantity purchased
    public func trackRevenue(
        productId: String,
        price: Double,
        currency: String = "USD",
        quantity: Int = 1
    ) {
        trackEvent(
            name: "purchase",
            parameters: [
                "product_id": productId,
                "price": price,
                "currency": currency,
                "quantity": quantity
            ]
        )
    }
    
    /// Track performance metrics
    /// - Parameters:
    ///   - metricName: The name of the performance metric
    ///   - value: The metric value
    ///   - unit: The unit of measurement
    public func trackPerformance(
        metricName: String,
        value: Double,
        unit: String = "ms"
    ) {
        performanceMetrics[metricName] = value
        
        trackEvent(
            name: "performance_metric",
            parameters: [
                "metric_name": metricName,
                "value": value,
                "unit": unit
            ]
        )
    }
    
    /// Track error events
    /// - Parameters:
    ///   - errorCode: The error code
    ///   - errorMessage: The error message
    ///   - errorType: The type of error
    public func trackError(
        errorCode: String,
        errorMessage: String,
        errorType: String = "general"
    ) {
        trackEvent(
            name: "app_error",
            parameters: [
                "error_code": errorCode,
                "error_message": errorMessage,
                "error_type": errorType
            ]
        )
    }
    
    /// Get current analytics session data
    /// - Returns: Analytics session information
    public func getSessionData() -> AnalyticsSessionData {
        return AnalyticsSessionData(
            sessionStartTime: sessionStartTime,
            currentScreen: currentScreen,
            isAnalyticsEnabled: isAnalyticsEnabled,
            performanceMetrics: performanceMetrics
        )
    }
    
    /// Enable or disable analytics collection
    /// - Parameter enabled: Whether analytics should be enabled
    public func setAnalyticsEnabled(_ enabled: Bool) {
        isAnalyticsEnabled = enabled
        analytics.setAnalyticsCollectionEnabled(enabled)
        print("📊 Analytics \(enabled ? "Enabled" : "Disabled")")
    }
    
    /// Reset analytics data (for testing purposes)
    public func resetAnalytics() {
        analytics.resetAnalyticsData()
        performanceMetrics.removeAll()
        currentScreen = nil
        sessionStartTime = nil
        print("📊 Analytics Reset")
    }
    
    // MARK: - Private Methods
    
    private func setupAnalytics() {
        // Configure analytics settings
        analytics.setAnalyticsCollectionEnabled(isAnalyticsEnabled)
        
        // Set default user properties
        setUserProperty(key: "app_version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
        setUserProperty(key: "platform", value: "iOS")
        setUserProperty(key: "device_model", value: UIDevice.current.model)
        
        print("📊 Analytics Setup Complete")
    }
    
    private func startSessionTracking() {
        sessionStartTime = Date()
        trackEvent(name: "session_start")
        print("📊 Session Started")
    }
    
    private func startScreenTrackingTimer(screenName: String) {
        screenTrackingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.trackScreenEngagement(screenName: screenName)
        }
    }
    
    private func stopScreenTracking() {
        screenTrackingTimer?.invalidate()
        screenTrackingTimer = nil
        
        if let screen = currentScreen, let startTime = sessionStartTime {
            let duration = Date().timeIntervalSince(startTime)
            trackEvent(
                name: "screen_duration",
                parameters: [
                    "screen_name": screen,
                    "duration": duration
                ]
            )
        }
    }
    
    private func trackScreenEngagement(screenName: String) {
        trackEvent(
            name: "screen_engagement",
            parameters: [
                "screen_name": screenName,
                "engagement_time": 30.0
            ]
        )
    }
}

// MARK: - Analytics Configuration
public struct AnalyticsConfiguration {
    public let isEnabled: Bool
    public let sessionTimeout: TimeInterval
    public let maxEventCount: Int
    
    public init(
        isEnabled: Bool = true,
        sessionTimeout: TimeInterval = 1800, // 30 minutes
        maxEventCount: Int = 1000
    ) {
        self.isEnabled = isEnabled
        self.sessionTimeout = sessionTimeout
        self.maxEventCount = maxEventCount
    }
}

// MARK: - Analytics Session Data
public struct AnalyticsSessionData {
    public let sessionStartTime: Date?
    public let currentScreen: String?
    public let isAnalyticsEnabled: Bool
    public let performanceMetrics: [String: TimeInterval]
    
    public var sessionDuration: TimeInterval {
        guard let startTime = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Analytics Event Types
public enum AnalyticsEventType: String, CaseIterable {
    case screenView = "screen_view"
    case userEngagement = "user_engagement"
    case purchase = "purchase"
    case conversion = "conversion"
    case error = "app_error"
    case performance = "performance_metric"
    case sessionStart = "session_start"
    case sessionEnd = "session_end"
}

// MARK: - Analytics Error Types
public enum AnalyticsError: LocalizedError {
    case eventTrackingFailed(Error)
    case invalidParameters([String])
    case analyticsDisabled
    
    public var errorDescription: String? {
        switch self {
        case .eventTrackingFailed(let error):
            return "Event tracking failed: \(error.localizedDescription)"
        case .invalidParameters(let params):
            return "Invalid parameters: \(params.joined(separator: ", "))"
        case .analyticsDisabled:
            return "Analytics is currently disabled"
        }
    }
} 