import SwiftUI

struct AIProviderSectionView: View {

    enum Constants {
        static let title = String(localized: "Choose your AI", comment: "Title for the AI provider section")
        static let color = Color.aiProviderColor
        static let titleIcon = "cpu"
    }

    @Binding var indexSelected: Int?

    @Environment(\.colorScheme) var colorScheme

    var buttonTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        VStack(alignment: .leading) {
            title
                .padding(.bottom)
            options
        }
    }

    private var title: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: Constants.titleIcon)
                .font(.system(size: 20))
                .foregroundStyle(Constants.color)
                .clipShape(.circle)
            Text(Constants.title)
                .font(.h5SemiBold)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var options: some View {
        HStack {
            Spacer()
            ForEach(Array(Story.AIProvider.allCases.enumerated()), id: \.offset) { index, option in
                makeOptionItem(title: option.title, icon: option.icon, index: index)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func makeOptionItem(title: String, icon: String, index: Int) -> some View {
        let isSelected = index == indexSelected
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            Task { @MainActor in
                indexSelected = index
            }
        }) {
            VStack {
                Text(icon)
                    .font(.system(size: 25))
                Text(title)
                    .foregroundStyle(buttonTextColor)
                    .font(.bodyRegular)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.color, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Constants.color.opacity(opacity))
            )
        }
    }
}

extension Story.AIProvider {
    var title: String {
        switch self {
        case .claude: "Claude"
        case .openai: "OpenAI"
        }
    }

    var icon: String {
        switch self {
        case .claude: "🧠"
        case .openai: "🤖"
        }
    }
}

#Preview {
    @Previewable @State var indexSelected: Int? = 0
    AIProviderSectionView(indexSelected: $indexSelected)
}
