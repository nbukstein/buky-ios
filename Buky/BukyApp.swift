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
    
    var sharedModelContainer: ModelContainer = {
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
        }
        .modelContainer(sharedModelContainer)
        
    }
}
