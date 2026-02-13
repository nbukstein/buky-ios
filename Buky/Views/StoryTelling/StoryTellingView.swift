import Lottie
import SwiftUI

struct StoryTellingView: View {

    enum Constants {
        static let title = String(localized: "Creating your story", comment: "Title for the screen")
        static let readOnlyTitle = String(localized: "Your story", comment: "Title for read-only story screen")
        static let loadingText = String(localized: "This can take some seconds...", comment: "Loading text while fetching story")
        static let headerSubtitle = String(localized: "What is your story about", comment: "Title for the saved new stories button")
        static let savedStoriesSectionSubtitle = String(localized: "Access your collection of magical tales. Read, share, or continue where you left off in your story adventures", comment: "Subtitle for the saved stories button")
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
            if viewModel.isLoading {
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
                    Text("Select the configurations to create the story")
                        .font(.bodySemiBold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .disabled(viewModel.isLoading || viewModel.isSaved)
                .padding()
                .padding(.horizontal)
                .background(.ultraThickMaterial)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
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
            .font(.bodySemiBold)
            .padding()
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
            viewModel.saveStory(context: modelContext)
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
                        Color.white.opacity(viewModel.isLoading || viewModel.isSaved ? 0.7 : 0)
                    )
                )
                .cornerRadius(15)
        }
        .disabled(viewModel.isSaved)
    }
}
