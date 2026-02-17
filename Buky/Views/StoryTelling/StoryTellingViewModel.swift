//
//  CreateStoryViewModel.swift
//  Buky
//
//  Created by Nicolas Bukstein on 5/2/26.
//

import SwiftUI
import SwiftData

final class StoryTellingViewModel: ObservableObject {
    @Published var story: Story
    @Published var text: String = ""

    @Published var storyBody = ""
    @Published var storyTitle = ""
    @Published var isLoadingStory = false
    @Published var finishedReceivingStory = false
    @Published var isSaved = false
    @Published var errorMessage: String?

    let isReadOnly: Bool

    let streamingChatAPI = StreamingChatAPI()

    // MARK: - Throttle
    private var chunkBuffer = ""
    private var flushTask: Task<Void, Never>?
    private let throttleInterval: UInt64 = 1000_000_000 // 80ms en nanosegundos

    private var storyText = "" {
        didSet {
            let title = Self.titleForStory(storyText)
            storyTitle = title

            if isLoadingStory && !title.isEmpty {
                isLoadingStory = false
            }

            storyBody = Self.bodyForStory(from: storyText)
        }
    }

    init(story: Story, isReadOnly: Bool = false) {
        self.story = story
        self.isReadOnly = isReadOnly

        if isReadOnly, let savedText = story.text {
            self.storyText = savedText
            self.storyBody = Self.bodyForStory(from: savedText)
            self.storyTitle = Self.titleForStory(savedText)
        }
    }

    @MainActor
    func onAppear() async {
        guard !isReadOnly else { return }
        isLoadingStory = true
        storyText = ""

        await streamingChatAPI.streamMessage(story) { chunk in
            Task { @MainActor in
                self.enqueueChunk(chunk)
            }
        } onComplete: {
            Task { @MainActor in
                self.flushBuffer()
                self.finishedReceivingStory = true
            }
        } onError: { error in
            print(error)
        }
    }

    @MainActor
    private func enqueueChunk(_ chunk: String) {
        chunkBuffer += chunk

        // Si ya hay un flush programado, no programar otro
        guard flushTask == nil else { return }

        flushTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: self.throttleInterval)
            self.flushBuffer()
        }
    }

    @MainActor
    private func flushBuffer() {
        guard !chunkBuffer.isEmpty else { return }
        let buffered = chunkBuffer
        chunkBuffer = ""
        flushTask?.cancel()
        flushTask = nil

        withAnimation(.easeIn(duration: 0.15)) {
            self.storyText += buffered
        }
    }

    func saveStory(context: ModelContext) {
        story.text = storyText
        context.insert(story)
        try? context.save()
        isSaved = true
    }
    
    
    static func bodyForStory(from inputString: String) -> String {
        // The pattern \\[.*?\\] matches:
        // \\[: A literal opening square bracket.
        // .*: Any character (except newline).
        // ?: Makes the match non-greedy (stops at the first closing bracket).
        // \\]: A literal closing square bracket.
        let pattern = "\\[.*?\\]"
        
        return inputString.replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression
        )
    }

    static func titleForStory(_ text: String) -> String {
        let pattern = #"\[(.*?)\]"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            
            // Obtenemos el rango del primer grupo de captura (índice 1)
            if let range = Range(match.range(at: 1), in: text) {
               return String(text[range])
            }
        }
        return ""
    }

}
