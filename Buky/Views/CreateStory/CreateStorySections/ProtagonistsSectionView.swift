import SwiftUI

struct ProtagonistsSectionView: View {
    
    enum Constants {
        static let title = String(localized: "Who do you want to be the main characters in the story?", comment: "Title for the place section")
        static let color = Color.orange
    }
    
    @Binding var indexesSelected: [Int]
    
    private let adapriveColumns = [GridItem(.adaptive(minimum: 120)), GridItem(.adaptive(minimum: 120))]
    
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
            Image(.people)
                .frame(width: 24, height: 24)
                .foregroundStyle(Constants.color)
                .clipShape(.circle)
                .scaledToFill()
            Text(Constants.title)
                .font(.h5SemiBold)
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private var options: some View {
        LazyVGrid(columns: adapriveColumns, spacing: 20){
            ForEach(Array(Story.Characters.allCases.enumerated()), id: \.offset) { index, option in
                makeOptionItem(
                    item: option,
                    index: index
                )
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func makeOptionItem(item: Story.Characters, index: Int) -> some View {
        let isSelected = indexesSelected.contains(index)
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            Task { @MainActor in
                if isSelected {
                    indexesSelected.removeAll(where: { $0 == index })
                } else {
                    indexesSelected.append(index)
                }
            }
        }) {
            VStack {
                Text(item.icon)
                    .font(.system(size: 25))
                    .foregroundStyle(Constants.color)
                    .padding()
                    .background(Constants.color.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                
                Text(item.title)
                    .font(.bodyRegular)
                    .foregroundStyle(buttonTextColor)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 120, height: 90)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Constants.color.opacity(opacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.color, lineWidth: 1)
                
            )
        }
        
    }
}

extension Story.Characters {
    
    var title: String {
        switch self {
        case .superhero: String(localized: "Superheroes", comment: "Title for superhero")
        case .animals: String(localized: "Animals", comment: "Title for animals")
        case .people: String(localized: "People", comment: "Title for people")
        case .dragons: String(localized: "Dragons", comment: "Title for dragons")
        case .princess: String(localized: "Princess", comment: "Title for princess")
        case .kings: String(localized: "Kings", comment: "Title for kings")
        }
    }

    var icon: String {
        switch self {
        case .superhero: "🦸"
        case .animals: "🐇"
        case .people: "👫"
        case .dragons: "🐉"
        case .princess: "👸"
        case .kings: "🤴"
        }
    }

    var subtypes: [Story.CharacterSubtype] {
        Story.CharacterSubtype.allCases.filter { $0.protagonistCategory == self }
    }

    var hasSubtypes: Bool {
        !subtypes.isEmpty
    }
}

#Preview {
    @Previewable @State var indexSelected: [Int] = []
    ProtagonistsSectionView(indexesSelected: $indexSelected)
}
