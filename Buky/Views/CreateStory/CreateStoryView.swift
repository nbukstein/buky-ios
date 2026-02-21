//
//  CreateStoryView.swift
//  Buky
//
//  Created by Nicolas Bukstein on 3/2/26.
//

import SwiftUI

struct CreateStoryView: View {
    
    enum Constants {
        static let title = String(localized: "Create story", comment: "Title for the screen")
        static let headerTitle = String(localized: "Lets create a new story", comment: "Subtitle for the create new story button")
        static let headerSubtitle = String(localized: "What is your story about", comment: "Title for the saved new stories button")
        static let savedStoriesSectionSubtitle = String(localized: "Access your collection of magical tales. Read, share, or continue where you left off in your story adventures", comment: "Subtitle for the saved stories button")
    }

    @StateObject var viewModel: CreateStoryViewModel

    @Environment(\.router) var router
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: CreateStoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        sectionsView
            .background(colorScheme == .dark ? Color.backgroundDark : Color.clear)
            .safeAreaInset(edge: .bottom) {
            VStack {
                bottomStickyButton
                Text("Select the configurations to create the story")
                    .font(.bodySemiBold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .disabled(!viewModel.isCreateStoryEnabled)
            .padding()
            .padding(.horizontal)
            .background(.ultraThickMaterial)
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private var bottomStickyButton: some View {
        Button(action: {
            router.showScreen(.push) { _ in
                StoryTellingView(viewModel: .init(story: viewModel.createStory()))
                    .modelContainer(BukyApp.sharedModelContainer)
            }
        }) {
            Text("Create story")
                .font(.h3Bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.tertiaryBrand, .cuarterlyBrand],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).overlay(
                        Color.white.opacity(viewModel.isCreateStoryEnabled ? 0 : 0.7)
                    )
                )
                .cornerRadius(15)
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer(minLength: 50)
            Image(systemName: "wand.and.sparkles")
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .padding()
                .background(headerGradient)
                .clipShape(.circle)
            Text(Constants.headerTitle)
                .font(.h3Bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding()
//        .edgesIgnoringSafeArea(.top)
    }
    
    
    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.primaryBrand, Color.secondaryBrand],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var sectionsView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    headerView
                    AgeSectionView(indexSelected: $viewModel.childAgeIndex)
                        .padding()
                    StoryLengthSectionView(indexSelected: $viewModel.storyLengthIndex)
                        .padding()
                    PlaceSectionView(indexSelected: $viewModel.placeIndex)
                        .padding()
                    ProtagonistsSectionView(indexesSelected: $viewModel.mainCharacterIndexes)
                        .padding()
                        .onChange(of: viewModel.mainCharacterIndexes) {
                            viewModel.onProtagonistsChanged()
                        }
                    if viewModel.showAnimalSection {
                        CharacterNameSectionView(
                            sectionTitle: String(localized: "Name your animal"),
                            sectionIcon: "pawprint.fill",
                            subtypes: Story.Characters.animals.subtypes,
                            indexSelected: $viewModel.animalTypeIndex,
                            characterName: $viewModel.animalName,
                            onFocusChanged: { isFocused in
                                if isFocused {
                                    withAnimation {
                                        proxy.scrollTo("animalNameSection", anchor: .center)
                                    }
                                }
                            }
                        )
                        .id("animalNameSection")
                        .padding()
                    }
                    if viewModel.showPeopleSection {
                        CharacterNameSectionView(
                            sectionTitle: String(localized: "Name your person"),
                            sectionIcon: "person.fill",
                            subtypes: Story.Characters.people.subtypes,
                            indexSelected: $viewModel.personTypeIndex,
                            characterName: $viewModel.personName,
                            onFocusChanged: { isFocused in
                                if isFocused {
                                    withAnimation {
                                        proxy.scrollTo("personNameSection", anchor: .center)
                                    }
                                }
                            }
                        )
                        .id("personNameSection")
                        .padding()
                    }
                    LessonsSectionView(indexSelected: $viewModel.lessonIndex)
                        .padding()
                    AIProviderSectionView(indexSelected: $viewModel.providerIndex)
                        .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
    
}

#Preview {
    CreateStoryView(viewModel: .init())
}
