import SwiftUI

struct LessonsSectionView: View {
    
    enum Constants {
        static let title = String(localized: "What is the lesson of the story?", comment: "Title for the lesson section")
        static let color = Color.red
        static let titleIcon = "heart.fill"
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

    private var options: some View {
        VStack {
            ForEach(Array(Story.Lesson.allCases.enumerated()), id: \.offset) { index, option in
                makeOptionItem(title: option.title, icon: option.icon, index: index)
            }
        }
    }

    @ViewBuilder
    private func makeOptionItem(title: String, icon: Image, index: Int) -> some View {
        let isSelected = index == indexSelected
        let checkMarkIcon = isSelected ? "checkmark.circle.fill" : "circle"
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            indexSelected = index
        }) {
            HStack {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Constants.color)
                    .padding()
                    Text(title)
                        .font(.bodyRegular)
                        .foregroundStyle(buttonTextColor)
                        .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: checkMarkIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(Constants.color)
                    .padding()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Constants.color.opacity(opacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.color, lineWidth: 1)
                
            )
            .padding(.horizontal)
        }
    }
}

extension Story.Lesson {
    
    enum Constants {
        static let shortTitle = String(localized: "Short", comment: "Title for the screen")
        static let shortSubtitle = String(localized: "5 minutes", comment: "Title for the screen")
        static let mediumTitle = String(localized: "Medium", comment: "Title for the screen")
        static let mediumSubtitle = String(localized: "10 minutes", comment: "Title for the screen")
        static let longTitle = String(localized: "Long", comment: "Title for the screen")
        static let longSubtitle = String(localized: "15 minutes", comment: "Title for the screen")
    }
    
    var title: String {
        switch self {
        case .respect: String(localized: "Respect", comment: "Title for the respect")
        case .empathy: String(localized: "Empathy", comment: "Title for the empathy")
        case .friendship: String(localized: "Friendship", comment: "Title for the friendship")
        case .love: String(localized: "Love", comment: "Title for the love")
        case .sharing: String(localized: "Sharing", comment: "Title for the sharing")
        case .brave: String(localized: "Brave", comment: "Title for the brave")
        case .quiteness: String(localized: "Quiteness", comment: "Title for the quiteness")
        }
    }

    var icon: Image {
        switch self {
        case .respect: Image(.respect)
        case .empathy: Image(.empathy)
        case .friendship: Image(.friendship)
        case .love: Image(.love)
        case .sharing: Image(.sharing)
        case .brave: Image(.brave)
        case .quiteness: Image(.quiteness)
        }
    }
}

#Preview {
    @Previewable @State var indexSelected: Int? = 0
    LessonsSectionView(indexSelected: $indexSelected)
}
