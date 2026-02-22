import SwiftUI
import SwiftfulRouting
import SwiftData
import RevenueCat

@main
struct BukyApp: App {

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        // For large titles:
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: "Quicksand-Bold", size: 30)!
        ]

        // For inline (small) titles:
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "Quicksand-Bold", size: 20)!
        ]

        Purchases.configure(withAPIKey: "test_DYxJizfDlSgDGpwKMhoqgVKfjim")

        // Initialize Analytics
        _ = AnalyticsManager.shared
    }
    
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Story.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RouterView { router in
                MenuView()
                    .edgesIgnoringSafeArea(.bottom)
            }
            .environmentObject(subscriptionManager)
            .task {
                await subscriptionManager.fetchProducts()
                await subscriptionManager.updatePurchasedProducts()

                // Track app launch
                AnalyticsManager.shared.trackAppLaunch()
            }
        }
        .modelContainer(BukyApp.sharedModelContainer)

    }
}
