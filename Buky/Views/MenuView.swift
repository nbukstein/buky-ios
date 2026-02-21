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
    @Environment(\.colorScheme) var colorScheme
    
    private var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    enum Constants {
        static let createNewStorySectionTitle = String(localized: "Create new story", comment: "Title for the create new story button")
        static let createNewStorySectionSubtitle = String(localized: "Use the magic of IA to create amazing stories. Set the characters, place and life lessons for your story", comment: "Subtitle for the create new story button")
        static let savedStoriesSectionTitle = String(localized: "Saved stories", comment: "Title for the saved new stories button")
        static let savedStoriesSectionSubtitle = String(localized: "Access your collection of magical tales. Read, share, or continue where you left off in your story adventures", comment: "Subtitle for the saved stories button")
    }

    var body: some View {
        VStack(spacing: 0) {
            headerContentView
            mainContentView
                .padding(.top, -15)
        }
    }

    private var headerContentView: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                Text("Make great stories using AI", comment: "")
                    .font(.h3Bold)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 25)
                    .padding(.horizontal)
            }
            Button {
                router.showScreen(.push) { _ in
                    SettingsView()
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(isDarkMode ? Color.backgroundDark : Color.clear)
                    .clipShape(Circle())
                    .shadow(color: isDarkMode ? .black.opacity(0.5) : .clear, radius: 8)
            }
            .padding(.top, 50)
            .padding(.leading, 10)
        }
        .background(
            Image(colorScheme == .dark ? .menuHeaderBackgorundDark : .menuHeaderBackgorund)
                .resizable()
                .scaledToFill()
        )
        
        .ignoresSafeArea(edges: .top)
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            sectionsView
                .padding(.top)
//            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDarkMode ? Color.backgroundDark : Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
            )
        )
        .edgesIgnoringSafeArea(.bottom)
    }

    private var sectionsView: some View {
        VStack {
//            Spacer()
            makeSection(title: Constants.createNewStorySectionTitle,
                        subtitle: Constants.createNewStorySectionSubtitle,
                        icon: "wand.and.sparkles",
                        firstColor: isDarkMode ? Color.tertiaryBrand : Color.tertiaryBrand,
                        lastColor: isDarkMode ? Color.cuarterlyBrand : Color.cuarterlyBrand
            ) {
                router.showScreen(.push) { _ in
                    CreateStoryView(viewModel: .init())
                        .modelContainer(BukyApp.sharedModelContainer)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Spacer()
            makeSection(title: Constants.savedStoriesSectionTitle,
                        subtitle: Constants.savedStoriesSectionSubtitle,
                        icon: "bookmark.fill",
                        firstColor: isDarkMode ? Color.savedColorOne : Color.savedColorOne,
                        lastColor: isDarkMode ? Color.savedColorTwo : Color.savedColorTwo
            ) {
                router.showScreen(.push) { _ in
                    SavedStoriesView()
                        .modelContainer(BukyApp.sharedModelContainer)
                }
            }
            .padding(.horizontal)
            Spacer()
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
//                    Image(systemName: icon)
//                        .font(.system(size: 15))
//                        .foregroundStyle(.white)
//                        .padding()
//                        .background(Color.white.opacity(0.3))
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack(alignment: .center) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
//                            .padding()
//                            .background(Color.white.opacity(0.3))
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Text(title)
                            .font(.h4SemiBold)
                            .foregroundColor(.white)
//                            .padding(.bottom)
                    }
                    .padding(.bottom)
                    Text(subtitle)
                        .font(.h5Medium)
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
                .overlay(Color.black.opacity(isDarkMode ? 0.45 : 0 ))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
        
    
}

#Preview {
    MenuView()
}
