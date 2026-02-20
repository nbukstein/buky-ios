import SwiftUI

struct ReadingTipsSheet: View {

    let isFirstTime: Bool

    @Environment(\.dismiss) private var dismiss

    @State private var hasScrolledToBottom = false
    @State private var timerFinished = false
    @State private var timerProgress: CGFloat = 0

    private var canDismiss: Bool {
        !isFirstTime || (hasScrolledToBottom && timerFinished)
    }

    private let tips = ReadingTip.all

    var body: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(tips) { tip in
                            tipRow(tip)
                        }
                        if isFirstTime && !hasScrolledToBottom {
                            scrollIndicator
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                            .onAppear {
                                hasScrolledToBottom = true
                            }
                    }
                    .padding()
                }
            }
            dismissButton
        }
        .interactiveDismissDisabled(isFirstTime && !canDismiss)
        .task {
            guard isFirstTime else {
                timerFinished = true
                timerProgress = 1
                return
            }
            withAnimation(.linear(duration: 12)) {
                timerProgress = 1
            }
            try? await Task.sleep(for: .seconds(12))
            timerFinished = true
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.pages")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.tertiaryBrand, .cuarterlyBrand],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("Tips for reading stories")
                .font(.h3Bold)
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private func tipRow(_ tip: ReadingTip) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(tip.icon)
                .font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.h5SemiBold)
                Text(tip.subtitle)
                    .font(.bodyRegular)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scrollIndicator: some View {
        HStack {
            Spacer()
            Label("Scroll down to read all tips", systemImage: "arrow.down")
                .font(.captionRegular)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 4)
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Got it!")
                .font(.h3Bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.tertiaryBrand, .cuarterlyBrand],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        GeometryReader { geo in
                            Color.white.opacity(0.5)
                                .frame(width: geo.size.width * (1 - timerProgress))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    )
                )
                .cornerRadius(15)
        }
        .disabled(!canDismiss)
        .padding()
    }
}
