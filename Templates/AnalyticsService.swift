// MARK: - Firebase Analytics Service Template
// Comprehensive analytics tracking service

import Foundation
import FirebaseAnalytics

/// Centralized analytics service for tracking user events and behavior
public final class AnalyticsService {
    
    // MARK: - Singleton
    
    public static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Enable or disable analytics collection
    public func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }
    
    /// Set user ID for analytics
    public func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
    }
    
    /// Set user property
    public func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    // MARK: - Screen Tracking
    
    /// Log screen view event
    public func logScreenView(
        screenName: String,
        screenClass: String? = nil
    ) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }
    
    // MARK: - Standard Events
    
    /// Log sign up event
    public func logSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// Log login event
    public func logLogin(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// Log search event
    public func logSearch(searchTerm: String) {
        Analytics.logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm
        ])
    }
    
    /// Log share event
    public func logShare(contentType: String, itemID: String, method: String) {
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: itemID,
            AnalyticsParameterMethod: method
        ])
    }
    
    /// Log select content event
    public func logSelectContent(contentType: String, itemID: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: itemID
        ])
    }
    
    // MARK: - E-commerce Events
    
    /// Log view item event
    public func logViewItem(item: AnalyticsItem) {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItems: [item.toDictionary()],
            AnalyticsParameterCurrency: item.currency ?? "USD",
            AnalyticsParameterValue: item.price ?? 0
        ])
    }
    
    /// Log add to cart event
    public func logAddToCart(item: AnalyticsItem, quantity: Int = 1) {
        var params = item.toDictionary()
        params[AnalyticsParameterQuantity] = quantity
        
        Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
            AnalyticsParameterItems: [params],
            AnalyticsParameterCurrency: item.currency ?? "USD",
            AnalyticsParameterValue: (item.price ?? 0) * Double(quantity)
        ])
    }
    
    /// Log remove from cart event
    public func logRemoveFromCart(item: AnalyticsItem, quantity: Int = 1) {
        var params = item.toDictionary()
        params[AnalyticsParameterQuantity] = quantity
        
        Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: [
            AnalyticsParameterItems: [params],
            AnalyticsParameterCurrency: item.currency ?? "USD",
            AnalyticsParameterValue: (item.price ?? 0) * Double(quantity)
        ])
    }
    
    /// Log begin checkout event
    public func logBeginCheckout(items: [AnalyticsItem], value: Double, currency: String = "USD") {
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
            AnalyticsParameterItems: items.map { $0.toDictionary() },
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterValue: value
        ])
    }
    
    /// Log purchase event
    public func logPurchase(
        transactionID: String,
        items: [AnalyticsItem],
        value: Double,
        currency: String = "USD",
        tax: Double? = nil,
        shipping: Double? = nil
    ) {
        var parameters: [String: Any] = [
            AnalyticsParameterTransactionID: transactionID,
            AnalyticsParameterItems: items.map { $0.toDictionary() },
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterValue: value
        ]
        
        if let tax = tax {
            parameters[AnalyticsParameterTax] = tax
        }
        
        if let shipping = shipping {
            parameters[AnalyticsParameterShipping] = shipping
        }
        
        Analytics.logEvent(AnalyticsEventPurchase, parameters: parameters)
    }
    
    // MARK: - Custom Events
    
    /// Log custom event
    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    /// Log button tap event
    public func logButtonTap(buttonName: String, screenName: String) {
        Analytics.logEvent("button_tap", parameters: [
            "button_name": buttonName,
            "screen_name": screenName
        ])
    }
    
    /// Log feature usage event
    public func logFeatureUsed(featureName: String, details: [String: Any]? = nil) {
        var parameters: [String: Any] = ["feature_name": featureName]
        
        if let details = details {
            for (key, value) in details {
                parameters[key] = value
            }
        }
        
        Analytics.logEvent("feature_used", parameters: parameters)
    }
    
    /// Log error event
    public func logError(errorType: String, errorMessage: String, screenName: String? = nil) {
        var parameters: [String: Any] = [
            "error_type": errorType,
            "error_message": errorMessage
        ]
        
        if let screenName = screenName {
            parameters["screen_name"] = screenName
        }
        
        Analytics.logEvent("app_error", parameters: parameters)
    }
    
    /// Log timing event
    public func logTiming(category: String, variable: String, value: TimeInterval) {
        Analytics.logEvent("timing", parameters: [
            "timing_category": category,
            "timing_variable": variable,
            "timing_value": Int(value * 1000) // Convert to milliseconds
        ])
    }
    
    // MARK: - Engagement Events
    
    /// Log tutorial begin
    public func logTutorialBegin() {
        Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
    }
    
    /// Log tutorial complete
    public func logTutorialComplete() {
        Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
    }
    
    /// Log level up (gamification)
    public func logLevelUp(level: Int, character: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameterLevel: level
        ]
        
        if let character = character {
            parameters[AnalyticsParameterCharacter] = character
        }
        
        Analytics.logEvent(AnalyticsEventLevelUp, parameters: parameters)
    }
    
    /// Log achievement unlocked
    public func logUnlockAchievement(achievementID: String) {
        Analytics.logEvent(AnalyticsEventUnlockAchievement, parameters: [
            AnalyticsParameterAchievementID: achievementID
        ])
    }
}

// MARK: - Analytics Item

public struct AnalyticsItem {
    public let itemID: String
    public let itemName: String
    public var itemCategory: String?
    public var itemBrand: String?
    public var price: Double?
    public var currency: String?
    public var quantity: Int?
    
    public init(
        itemID: String,
        itemName: String,
        itemCategory: String? = nil,
        itemBrand: String? = nil,
        price: Double? = nil,
        currency: String? = nil,
        quantity: Int? = nil
    ) {
        self.itemID = itemID
        self.itemName = itemName
        self.itemCategory = itemCategory
        self.itemBrand = itemBrand
        self.price = price
        self.currency = currency
        self.quantity = quantity
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            AnalyticsParameterItemID: itemID,
            AnalyticsParameterItemName: itemName
        ]
        
        if let category = itemCategory {
            dict[AnalyticsParameterItemCategory] = category
        }
        
        if let brand = itemBrand {
            dict[AnalyticsParameterItemBrand] = brand
        }
        
        if let price = price {
            dict[AnalyticsParameterPrice] = price
        }
        
        if let quantity = quantity {
            dict[AnalyticsParameterQuantity] = quantity
        }
        
        return dict
    }
}

// MARK: - Usage Example
/*
 
 // 1. Track screen view
 AnalyticsService.shared.logScreenView(screenName: "HomeScreen")
 
 // 2. Track user action
 AnalyticsService.shared.logButtonTap(buttonName: "purchase", screenName: "ProductDetail")
 
 // 3. Track e-commerce
 let item = AnalyticsItem(
     itemID: "SKU123",
     itemName: "iPhone Case",
     itemCategory: "Accessories",
     price: 29.99,
     currency: "USD"
 )
 AnalyticsService.shared.logAddToCart(item: item)
 
 // 4. Track purchase
 AnalyticsService.shared.logPurchase(
     transactionID: "TXN123",
     items: [item],
     value: 29.99,
     currency: "USD",
     tax: 2.50,
     shipping: 5.00
 )
 
 // 5. Track custom event
 AnalyticsService.shared.logEvent("custom_action", parameters: [
     "action_type": "export",
     "file_format": "pdf"
 ])
 
 */
