import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    private let subscriptionManager = SubscriptionManager.shared

    var isSubscribed: Bool {
        subscriptionManager.isSubscribed
    }

    var currentTierLabel: String {
        switch subscriptionManager.currentSubscriptionTier {
        case .yearly:
            return String(localized: "Yearly plan", comment: "Yearly subscription tier")
        case .monthly:
            return String(localized: "Monthly plan", comment: "Monthly subscription tier")
        case .none:
            return ""
        }
    }
}
