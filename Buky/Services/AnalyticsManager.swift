import Foundation
import Mixpanel

/// Centralized analytics service wrapping Mixpanel for event tracking throughout the app.
/// All analytics events should flow through this service to ensure consistency and maintainability.
@MainActor
final class AnalyticsManager {

    // MARK: - Singleton

    static let shared = AnalyticsManager()

    // MARK: - Constants

    #if DEBUG
    private let mixpanelToken = "bb6592de0b806805aa85ba27ee5b6330"
    #else
    private let mixpanelToken = "8f0dad84075edbf63f785cda06b13505"
    #endif

    // MARK: - Cached Properties

    /// The user's persistent UUID, loaded once at initialization from UserStorageManager.
    /// This is cached in memory for the entire app lifecycle to avoid repeated storage reads.
    private let userID: String

    // MARK: - Computed Properties

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    // MARK: - Initialization

    private init() {
        // Load the user ID once from UserStorageManager (which handles iCloud + UserDefaults)
        self.userID = UserStorageManager.shared.userID

        // Initialize Mixpanel
        Mixpanel.initialize(token: mixpanelToken, trackAutomaticEvents: false)

        // Identify the user with their persistent UUID
        Mixpanel.mainInstance().identify(distinctId: userID)

        // Set user properties
        Mixpanel.mainInstance().people.set(properties: [
            "user_id": userID,
            "platform": "iOS",
            "app_version": appVersion
        ])
    }

    // MARK: - Event Tracking

    /// Track a generic event with properties
    func track(event: String, properties: [String: MixpanelType]? = nil) {
        var mergedProperties = commonProperties()

        if let properties = properties {
            mergedProperties.merge(properties) { _, new in new }
        }

        Mixpanel.mainInstance().track(event: event, properties: mergedProperties)
    }

    /// Common properties included in all events
    private func commonProperties() -> [String: MixpanelType] {
        let isSubscribed = SubscriptionManager.shared.isSubscribed

        return [
            "user_id": userID,
            "platform": "iOS",
            "app_version": appVersion,
            "is_subscribed": isSubscribed,
            "timestamp": Date().timeIntervalSince1970
        ]
    }

    // MARK: - Navigation Events

    func trackScreenClosed(screenName: String, action: String = "back") {
        track(event: "Screen Closed", properties: [
            "screen_name": screenName,
            "action": action
        ])
    }

    // MARK: - App Launch Events

    func trackAppLaunch() {
        track(event: "App Launched")
    }

    // MARK: - Screen View Events

    func trackScreenView(screenName: String, source: String? = nil) {
        var properties: [String: MixpanelType] = [
            "screen_name": screenName
        ]

        if let source = source {
            properties["source"] = source
        }

        track(event: "Screen Viewed", properties: properties)
    }

    // MARK: - Menu Events

    func trackMenuAction(action: String) {
        track(event: "Menu Action", properties: [
            "action": action
        ])
    }

    // MARK: - Story Configuration Events

    func trackStoryConfigurationSelected(configurationType: String, value: String) {
        track(event: "Story Configuration Selected", properties: [
            "configuration_type": configurationType,
            "value": value
        ])
    }

    func trackCreateStoryButtonTapped(story: Story) {
        var properties = storyProperties(from: story)
        properties["action"] = "create_story_tapped"

        track(event: "Create Story Button Tapped", properties: properties)
    }

    // MARK: - Story Telling Events

    func trackStoryStreamingStarted(story: Story) {
        var properties = storyProperties(from: story)
        properties["event_type"] = "streaming_started"

        track(event: "Story Streaming Started", properties: properties)
    }

    func trackStoryStreamingCompleted(story: Story) {
        var properties = storyProperties(from: story)
        properties["event_type"] = "streaming_completed"

        track(event: "Story Streaming Completed", properties: properties)
    }

    func trackStorySaved(story: Story) {
        var properties = storyProperties(from: story)
        properties["event_type"] = "story_saved"

        track(event: "Story Saved", properties: properties)
    }

    // MARK: - Saved Stories Events

    func trackSavedStoryOpened(story: Story) {
        var properties = storyProperties(from: story)
        properties["event_type"] = "saved_story_opened"

        track(event: "Saved Story Opened", properties: properties)
    }

    // MARK: - Settings Events

    func trackSettingsAction(action: String) {
        track(event: "Settings Action", properties: [
            "action": action
        ])
    }

    // MARK: - Subscription Events

    func trackSubscriptionScreenViewed(source: String? = nil) {
        var properties: [String: MixpanelType] = [
            "screen_name": "Subscription"
        ]

        if let source = source {
            properties["source"] = source
        }

        track(event: "Subscription Screen Viewed", properties: properties)
    }

    func trackSubscriptionPlanSelected(planType: String, price: String? = nil) {
        var properties: [String: MixpanelType] = [
            "plan_type": planType
        ]

        if let price = price {
            properties["price"] = price
        }

        track(event: "Subscription Plan Selected", properties: properties)
    }

    func trackPurchaseInitiated(planType: String, price: String? = nil) {
        var properties: [String: MixpanelType] = [
            "plan_type": planType
        ]

        if let price = price {
            properties["price"] = price
        }

        track(event: "Purchase Initiated", properties: properties)
    }

    func trackPurchaseCompleted(planType: String, price: String? = nil) {
        var properties: [String: MixpanelType] = [
            "plan_type": planType
        ]

        if let price = price {
            properties["price"] = price
        }

        // Update user property
        Mixpanel.mainInstance().people.set(properties: [
            "is_subscribed": true,
            "subscription_plan": planType
        ])

        track(event: "Purchase Completed", properties: properties)
    }

    func trackPurchaseFailed(planType: String, error: String? = nil) {
        var properties: [String: MixpanelType] = [
            "plan_type": planType
        ]

        if let error = error {
            properties["error_message"] = error
        }

        track(event: "Purchase Failed", properties: properties)
    }

    func trackRestorePurchases() {
        track(event: "Restore Purchases Tapped")
    }

    // MARK: - Reading Tips Events

    func trackReadingTipsShown(isFirstTime: Bool) {
        track(event: "Reading Tips Shown", properties: [
            "is_first_time": isFirstTime
        ])
    }

    func trackReadingTipsDismissed(isFirstTime: Bool) {
        track(event: "Reading Tips Dismissed", properties: [
            "is_first_time": isFirstTime
        ])
    }

    // MARK: - Helper Methods

    /// Extract story properties for events
    private func storyProperties(from story: Story) -> [String: MixpanelType] {
        var properties: [String: MixpanelType] = [:]

        if let childAge = story.childAge {
            properties["child_age"] = childAge.ageRange
        }

        if let storyLength = story.storyTimeLength {
            properties["story_length"] = storyLength.apiValue
        }

        if let place = story.place {
            properties["place"] = place.rawValue
        }

        if !story.characters.isEmpty {
            let charactersArray = story.characters.map { $0.rawValue }
            properties["characters"] = charactersArray
        }

        if let lesson = story.lesson {
            properties["lesson"] = lesson.rawValue
        }

        if let animalType = story.animalType {
            properties["animal_type"] = animalType.rawValue
        }

        if let animalName = story.animalName, !animalName.isEmpty {
            properties["animal_name"] = animalName
        }

        if let personType = story.personType {
            properties["person_type"] = personType.rawValue
        }

        if let personName = story.personName, !personName.isEmpty {
            properties["person_name"] = personName
        }

        if let language = story.language {
            properties["language"] = language
        }

        return properties
    }
}
