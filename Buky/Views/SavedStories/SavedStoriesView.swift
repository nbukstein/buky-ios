//
//  SavedStoriesView.swift
//  Buky
//
//  Created by Claude on 13/2/26.
//

import SwiftUI
import SwiftData
import SwiftfulRouting

struct SavedStoriesView: View {

    @Query(sort: \Story.dateCreated, order: .reverse) private var stories: [Story]
    @Environment(\.router) var router

    var body: some View {
        Group {
            if stories.isEmpty {
                emptyStateView
            } else {
                storiesListView
            }
        }
        .navigationTitle("Saved stories")
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))
            Text("No saved stories yet")
                .font(.h3Bold)
                .foregroundColor(.gray)
            Text("Create a story and save it to see it here")
                .font(.bodyRegular)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    private var storiesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(stories) { story in
                    storyCard(story: story)
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                StoryTellingView(viewModel: .init(story: story, isReadOnly: true))
                            }
                        }
                }
            }
            .padding()
        }
    }

    private func storyCard(story: Story) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text({
                    let title = StoryTellingViewModel.titleForStory(story.text ?? "")
                    return title.isEmpty ? "Untitled Story" : title
                }())
                .font(.h5SemiBold)
                .foregroundColor(.white)
                .lineLimit(2)

            GridChipsView(story: story)

            if let date = story.dateCreated {
                Text(date, style: .date)
                    .font(.captionRegular)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [.savedColorOne, .savedColorTwo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

}
