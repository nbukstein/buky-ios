//
//  StoryLimitManager.swift
//  Buky
//
//  Created by Nicolas Bukstein on 21/2/26.
//

import Foundation

@MainActor
final class StoryLimitManager: ObservableObject {

    static let shared = StoryLimitManager()

    // MARK: - Constants

    private enum Limit {
        static let subscribed = 120
        static let unsubscribed = 5
    }

    private enum DefaultsKey {
        static let storyCount = "storyCount"
        static let periodStartDate = "periodStartDate"
        static let subscriptionStartDate = "subscriptionStartDate"
        static let subscriptionTier = "subscriptionTier"
    }

    // MARK: - Published Properties

    @Published private(set) var storiesRemaining: Int = 0

    // MARK: - Private Properties

    private let defaults = UserDefaults.standard

    private var storyCount: Int {
        get { defaults.integer(forKey: DefaultsKey.storyCount) }
        set { defaults.set(newValue, forKey: DefaultsKey.storyCount) }
    }

    private var periodStartDate: Date? {
        get { defaults.object(forKey: DefaultsKey.periodStartDate) as? Date }
        set { defaults.set(newValue, forKey: DefaultsKey.periodStartDate) }
    }

    // MARK: - Init

    private init() {
        resetIfNewPeriod()
        updateStoriesRemaining()
    }

    // MARK: - Public API

    var canCreateStory: Bool {
        resetIfNewPeriod()
        updateStoriesRemaining()
        return storiesRemaining > 0
    }

    func recordStoryCreation() {
        storyCount += 1
        updateStoriesRemaining()
    }

    func onSubscriptionChanged(tier: SubscriptionManager.ProductID?) {
        if let tier {
            defaults.set(Date(), forKey: DefaultsKey.subscriptionStartDate)
            defaults.set(tier.rawValue, forKey: DefaultsKey.subscriptionTier)
        } else {
            defaults.removeObject(forKey: DefaultsKey.subscriptionTier)
        }
        storyCount = 0
        periodStartDate = Date()
        updateStoriesRemaining()
    }

    // MARK: - Private Helpers

    private func resetIfNewPeriod() {
        let now = Date()
        let calendar = Calendar.current

        guard let start = periodStartDate else {
            periodStartDate = now
            storyCount = 0
            return
        }

        let isSubscribed = SubscriptionManager.shared.isSubscribed

        if isSubscribed {
            if !calendar.isDate(start, equalTo: now, toGranularity: .month) {
                storyCount = 0
                periodStartDate = now
            }
        } else {
            if let days = calendar.dateComponents([.day], from: start, to: now).day, days >= 7 {
                storyCount = 0
                periodStartDate = now
            }
        }
    }

    private func updateStoriesRemaining() {
        let isSubscribed = SubscriptionManager.shared.isSubscribed
        let limit = isSubscribed ? Limit.subscribed : Limit.unsubscribed
        storiesRemaining = max(limit - storyCount, 0)
    }
}
