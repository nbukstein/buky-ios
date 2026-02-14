//
//  ContentView.swift
//  Buky
//
//  Created by Nicolas Bukstein on 28/1/26.
//

import SwiftfulRouting
import SwiftUI
import SwiftData

struct MenuView: View {
    
    @Environment(\.router) var router
    
    enum Constants {
        static let createNewStorySectionTitle = String(localized: "Create new story", comment: "Title for the create new story button")
        static let createNewStorySectionSubtitle = String(localized: "Use the magic of IA to create amazing stories. Set the characters, place and life lessons for your story", comment: "Subtitle for the create new story button")
        static let savedStoriesSectionTitle = String(localized: "Saved stories", comment: "Title for the saved new stories button")
        static let savedStoriesSectionSubtitle = String(localized: "Access your collection of magical tales. Read, share, or continue where you left off in your story adventures", comment: "Subtitle for the saved stories button")
    }

    var body: some View {
        VStack {
            headerContentView
            mainContentView
        }
        .padding(.top)
        .background(
            headerGradient
        )
    }

    private var headerContentView: some View {
        VStack {
            Image(.stories).padding(-20)
            Text("Buky story maker", comment: "")
                .font(.h2Bold)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
            Text("Make great stories using AI", comment: "")
                .font(.h5SemiBold)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
        }
    }

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.primaryBrand, Color.secondaryBrand],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var mainContentView: some View {
        VStack {
            subtitleView
            sectionsView
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
                // bottomLeadingRadius and bottomTrailingRadius default to 0
            )
        )
        .edgesIgnoringSafeArea(.bottom)
    }

    private var subtitleView: some View {
        VStack {
            Text("Hi little writer")
                .font(.h3Bold)
                .foregroundColor(.black)
                .padding(.top)
            Text("What would you like to do today?")
                .font(.captionRegular)
                .foregroundColor(.black)
        }
    }

    private var sectionsView: some View {
        VStack {
            makeSection(title: Constants.createNewStorySectionTitle,
                        subtitle: Constants.createNewStorySectionSubtitle,
                        icon: "wand.and.sparkles",
                        firstColor: Color.tertiaryBrand,
                        lastColor: Color.cuarterlyBrand
            ) {
                router.showScreen(.push) { _ in
                    CreateStoryView(viewModel: .init())
                        .modelContainer(BukyApp.sharedModelContainer)
                }
            }
            .padding()
            makeSection(title: Constants.savedStoriesSectionTitle,
                        subtitle: Constants.savedStoriesSectionSubtitle,
                        icon: "bookmark.fill",
                        firstColor: Color.savedColorOne,
                        lastColor: Color.savedColorTwo
            ) {
                router.showScreen(.push) { _ in
                    SavedStoriesView()
                        .modelContainer(BukyApp.sharedModelContainer)
                }
            }
            .padding(.horizontal).padding(.top)
        }
    }

    private func makeSection(
        title: String,
        subtitle: String,
        icon: String,
        firstColor: Color,
        lastColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text(title)
                        .font(.h5SemiBold)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.bodyRegular)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 24))          // Adjusts the size
                    .foregroundStyle(.white)
                
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [firstColor, lastColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
        
    
}

#Preview {
    MenuView()
}
