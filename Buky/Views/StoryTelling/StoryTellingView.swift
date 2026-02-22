import Lottie
import SwiftUI

struct StoryTellingView: View {

    enum Constants {
        static let title = String(localized: "Creating your story", comment: "Title for the screen")
        static let readOnlyTitle = String(localized: "Your story", comment: "Title for read-only story screen")
        static let loadingText = String(localized: "This can take some seconds...", comment: "Loading text while fetching story")
        static let headerSubtitle = String(localized: "What is your story about", comment: "Title for the saved new stories button")
        static let savedStoriesSectionSubtitle = String(localized: "Access your collection of magical tales. Read, share, or continue where you left off in your story adventures", comment: "Subtitle for the saved stories button")
        static let storySavedTitle = String(localized: "Story saved", comment: "Title for the saved new stories button")
        static let saveStoryTutle = String(localized: "Save story", comment: "Title for the save story button")
    }

    @StateObject var viewModel: StoryTellingViewModel

    @Environment(\.router) var router
    @Environment(\.modelContext) var modelContext

    private let adapriveColumns = [GridItem(.adaptive(minimum: 120)), GridItem(.adaptive(minimum: 120))]

    init(viewModel: StoryTellingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if viewModel.isLoadingStory {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.isReadOnly ? Constants.readOnlyTitle : Constants.title)
        .safeAreaInset(edge: .bottom) {
            if !viewModel.isReadOnly {
                VStack {
                    bottomStickyButton
                    Text("If your child liked the story, save it for next time!")
                        .font(.bodySemiBold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .disabled(viewModel.isLoadingStory || viewModel.isSaved)
                .padding()
                .padding(.horizontal)
                .background(.ultraThickMaterial)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear {
            let screenName = viewModel.isReadOnly ? "Story Telling (Read Only)" : "Story Telling"
            AnalyticsManager.shared.trackScreenClosed(screenName: screenName)
        }
        .onAppear {
            if viewModel.isReadOnly {
                AnalyticsManager.shared.trackScreenView(screenName: "Story Telling (Read Only)", source: "Saved Stories")
            } else {
                AnalyticsManager.shared.trackScreenView(screenName: "Story Telling", source: "Create Story")
            }
            viewModel.checkReadingTips()
            Task {
                await viewModel.onAppear()
            }
        }
        .sheet(isPresented: $viewModel.showReadingTips) {
            viewModel.onReadingTipsDismissed()
        } content: {
            ReadingTipsSheet(isFirstTime: viewModel.isFirstTimeTips)
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            LottieView(animation: .named("Writing man"))
                .looping()
                .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop))) // Configures playback
                .frame(width: 300, height: 300)
            Text(Constants.loadingText)
                .font(.bodyRegular)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }

    private var contentView: some View {
        VStack {
            storyHeaderView
            ScrollView {
                storyBodyView
                if viewModel.finishedReceivingStory {
                    feedbackView
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding()
    }

    private var storyBodyView: some View {
        Text(viewModel.storyBody)
            .font(.h5Medium)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var feedbackView: some View {
        HStack(spacing: 24) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation {
                    viewModel.sendFeedback(rating: false)
                }
            } label: {
                Image(systemName: viewModel.feedbackGiven == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
            .disabled(viewModel.feedbackGiven != nil)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation {
                    viewModel.sendFeedback(rating: true)
                }
            } label: {
                Image(systemName: viewModel.feedbackGiven == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .disabled(viewModel.feedbackGiven != nil)
        }
        .padding(.top, 8)
    }

    private var storyHeaderView: some View {
        VStack(alignment: .leading) {
            Text(viewModel.storyTitle)
                .font(.h3Bold)
            GridChipsView(story: viewModel.story)
        }
    }


    private var bottomStickyButton: some View {
        Button(action: {
            AnalyticsManager.shared.trackStorySaved(story: viewModel.story)
            viewModel.saveStory(context: modelContext)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                router.dismissAllScreens()
            }
        }) {
            Text(viewModel.isSaved ? "Story Saved" : "Save Story")
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
                        Color.white.opacity(!viewModel.finishedReceivingStory || viewModel.isSaved ? 0.7 : 0)
                    )
                )
                .cornerRadius(15)
        }
        .disabled(!viewModel.finishedReceivingStory)
    }
}
