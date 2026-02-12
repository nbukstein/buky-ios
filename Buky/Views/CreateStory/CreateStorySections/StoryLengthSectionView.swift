import SwiftUI

struct StoryLengthSectionView: View {
    
    enum Constants {
        static let title = String(localized: "How long do you want your story?", comment: "Title for the screen")
        static let color = Color.secondaryBrand
        static let titleIcon = "clock.fill"
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
            ForEach(Array(Story.TimeLength.allCases.enumerated()), id: \.offset) { index, option in
                makeOptionItem(title: option.title, subtitle: option.subtitle, icon: option.icon, index: index)
            }
        }
    }

    @ViewBuilder
    private func makeOptionItem(title: String, subtitle: String,  icon: String, index: Int) -> some View {
        let isSelected = index == indexSelected
        let checkMarkIcon = isSelected ? "checkmark.circle.fill" : "circle"
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            indexSelected = index
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Constants.color)
                    .padding()
                    .background(Constants.color.opacity(0.3))
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    Text(title)
                        .font(.bodyRegular)
                        .foregroundStyle(buttonTextColor)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.captionRegular)
                        .foregroundStyle(buttonTextColor)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                Image(systemName: checkMarkIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(Constants.color)
                    .padding()
                
                //checkmark.circle.fill
                
                //circle
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

extension Story.TimeLength {
    
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
        case .short: Constants.shortTitle
        case .medium: Constants.mediumTitle
        case .long: Constants.longTitle
        }
    }

    var subtitle: String {
        switch self {
        case .short: Constants.shortSubtitle
        case .medium: Constants.mediumSubtitle
        case .long: Constants.longSubtitle
        }
    }

    var icon: String {
        switch self {
        case .short: "bolt.fill"
        case .medium: "book.pages"
        case .long: "book.fill"
        }
    }
}

#Preview {
    @Previewable @State var indexSelected: Int? = 0
    StoryLengthSectionView(indexSelected: $indexSelected)
}
