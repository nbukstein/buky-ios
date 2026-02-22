//
//  NotificationManager.swift
//  Buky
//
//  Created by Nicolas Bukstein on 22/2/26.
//

import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    // MARK: - Constants

    private enum Constants {
        static let reminderIdentifier = "inactivity_reminder"
        static let inactivityDays = 3
        static let reminderHour = 19 // 7 PM
        static let maxReminders = 4
        static let sentCountKey = "inactivity_reminder_sent_count"
        static let scheduledFireDateKey = "inactivity_reminder_fire_date"

        static let milestoneIdentifier = "first_story_milestone"
        static let milestoneScheduledKey = "first_story_milestone_scheduled"
        static let milestoneDays = 7
        static let milestoneHour = 18 // 6 PM
        static let milestoneMinute = 30
    }

    private static let messages: [String] = [
        String(localized: "Your little one is waiting for a new bedtime story! Come create one together.", comment: "Inactivity reminder notification message"),
        String(localized: "It's been a while! A magical story is just a few taps away.", comment: "Inactivity reminder notification message"),
        String(localized: "Story time is the best time. Come back and create a new adventure!", comment: "Inactivity reminder notification message"),
        String(localized: "New characters and places are waiting to be discovered. Create a story today!", comment: "Inactivity reminder notification message"),
        String(localized: "Bedtime is better with a story. Let's create one together!", comment: "Inactivity reminder notification message")
    ]

    // MARK: - Private Properties

    private let defaults = UserDefaults.standard

    private var sentCount: Int {
        get { defaults.integer(forKey: Constants.sentCountKey) }
        set { defaults.set(newValue, forKey: Constants.sentCountKey) }
    }

    private var scheduledFireDate: Date? {
        get { defaults.object(forKey: Constants.scheduledFireDateKey) as? Date }
        set { defaults.set(newValue, forKey: Constants.scheduledFireDateKey) }
    }

    // MARK: - Init

    private init() {
        requestAuthorization()
    }

    // MARK: - Public API

    func scheduleInactivityReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Constants.reminderIdentifier])

        // If a previous notification's fire date has passed, it was delivered
        if let fireDate = scheduledFireDate, fireDate <= Date() {
            sentCount += 1
            scheduledFireDate = nil
        }

        guard sentCount < Constants.maxReminders else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Buky", comment: "App name used in notification title")
        content.body = Self.messages.randomElement()!
        content.sound = .default

        let fireDate = Calendar.current.date(
            byAdding: .day,
            value: Constants.inactivityDays,
            to: Date()
        )!
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        dateComponents.hour = Constants.reminderHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
        scheduledFireDate = trigger.nextTriggerDate()
    }

    func scheduleFirstStoryMilestone() {
        guard !defaults.bool(forKey: Constants.milestoneScheduledKey) else { return }
        defaults.set(true, forKey: Constants.milestoneScheduledKey)

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Buky", comment: "App name used in notification title")
        content.body = String(localized: "One week since you created your first story! Don't lose the magic.", comment: "First story milestone notification message")
        content.sound = .default

        let fireDate = Calendar.current.date(
            byAdding: .day,
            value: Constants.milestoneDays,
            to: Date()
        )!
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        dateComponents.hour = Constants.milestoneHour
        dateComponents.minute = Constants.milestoneMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.milestoneIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Constants.reminderIdentifier])
    }

    // MARK: - Private Helpers

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}
