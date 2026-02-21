//
//  BukyApp.swift
//  Buky
//
//  Created by Nicolas Bukstein on 28/1/26.
//

import SwiftUI
import SwiftfulRouting
import SwiftData

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
            }
        }
        .modelContainer(BukyApp.sharedModelContainer)
        
    }
}
