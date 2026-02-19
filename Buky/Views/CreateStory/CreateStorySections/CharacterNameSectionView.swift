import SwiftUI

struct CharacterNameSectionView: View {

    static let color = Color.characterNameColor
    static let chipIcon = "person.text.rectangle"

    let sectionTitle: String
    let sectionIcon: String
    let subtypes: [Story.CharacterSubtype]
    @Binding var indexSelected: Int?
    @Binding var characterName: String
    var onFocusChanged: ((Bool) -> Void)?

    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    var buttonTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        VStack(alignment: .leading) {
            title
                .padding(.bottom)
            options
            if indexSelected != nil {
                nameField
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
        }
    }

    private var title: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: sectionIcon)
                .font(.system(size: 20))
                .foregroundStyle(Self.color)
                .clipShape(.circle)
            Text(sectionTitle)
                .font(.h5SemiBold)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private var options: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(subtypes.enumerated()), id: \.offset) { index, option in
                    makeOptionItem(item: option, index: index)
                }
            }
            .padding(.horizontal)
        }
    }

    private var nameField: some View {
        TextField(
            String(localized: "Enter the character's name", comment: "Placeholder for character name field"),
            text: $characterName
        )
        .focused($isFocused)
        .onChange(of: isFocused) { _, newValue in
            onFocusChanged?(newValue)
        }
        .font(.bodyRegular)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Self.color, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Self.color.opacity(characterName.isEmpty ? 0 : 0.1))
        )
    }

    @ViewBuilder
    private func makeOptionItem(item: Story.CharacterSubtype, index: Int) -> some View {
        let isSelected = index == indexSelected
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            Task { @MainActor in
                indexSelected = isSelected ? nil : index
            }
        }) {
            VStack {
                Text(item.icon)
                    .font(.system(size: 25))
                Text(item.title)
                    .foregroundStyle(buttonTextColor)
                    .font(.bodyRegular)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Self.color, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Self.color.opacity(opacity))
            )
        }
    }
}

extension Story.CharacterSubtype {

    var protagonistCategory: Story.Characters {
        switch self {
        case .dog, .cat, .frog, .elephant, .lion, .butterfly, .cow:
            .animals
        case .uncle, .aunt, .brother, .sister, .cousinBoy, .cousinGirl, .grandpa, .grandma, .person:
            .people
        }
    }

    var title: String {
        switch self {
        // Animals
        case .dog: String(localized: "Dog", comment: "Character subtype")
        case .cat: String(localized: "Cat", comment: "Character subtype")
        case .frog: String(localized: "Frog", comment: "Character subtype")
        case .elephant: String(localized: "Elephant", comment: "Character subtype")
        case .lion: String(localized: "Lion", comment: "Character subtype")
        case .butterfly: String(localized: "Butterfly", comment: "Character subtype")
        case .cow: String(localized: "Cow", comment: "Character subtype")
        // People
        case .uncle: String(localized: "Uncle", comment: "Character subtype")
        case .aunt: String(localized: "Aunt", comment: "Character subtype")
        case .brother: String(localized: "Brother", comment: "Character subtype")
        case .sister: String(localized: "Sister", comment: "Character subtype")
        case .cousinBoy: String(localized: "Cousin (boy)", comment: "Character subtype")
        case .cousinGirl: String(localized: "Cousin (girl)", comment: "Character subtype")
        case .grandpa: String(localized: "Grandpa", comment: "Character subtype")
        case .grandma: String(localized: "Grandma", comment: "Character subtype")
        case .person: String(localized: "Person", comment: "Character subtype")
        }
    }

    var icon: String {
        switch self {
        // Animals
        case .dog: "🐶"
        case .cat: "🐱"
        case .frog: "🐸"
        case .elephant: "🐘"
        case .lion: "🦁"
        case .butterfly: "🦋"
        case .cow: "🐮"
        // People
        case .uncle: "🧔"
        case .aunt: "👱‍♀️"
        case .brother: "👦"
        case .sister: "👧"
        case .cousinBoy: "🧑"
        case .cousinGirl: "👩"
        case .grandpa: "👴"
        case .grandma: "👵"
        case .person: "🙂"
        }
    }

    var englishName: String {
        switch self {
        // Animals
        case .dog: "dog"
        case .cat: "cat"
        case .frog: "frog"
        case .elephant: "elephant"
        case .lion: "lion"
        case .butterfly: "butterfly"
        case .cow: "cow"
        // People
        case .uncle: "uncle"
        case .aunt: "aunt"
        case .brother: "brother"
        case .sister: "sister"
        case .cousinBoy, .cousinGirl: "cousin"
        case .grandpa: "grandpa"
        case .grandma: "grandma"
        case .person: "person"
        }
    }

    var englishArticle: String {
        switch self {
        case .uncle, .aunt, .elephant: "an"
        default: "a"
        }
    }

}

#Preview {
    @Previewable @State var indexSelected: Int? = 0
    @Previewable @State var name: String = ""
    CharacterNameSectionView(
        sectionTitle: "Name your animal",
        sectionIcon: "pawprint.fill",
        subtypes: Story.Characters.animals.subtypes,
        indexSelected: $indexSelected,
        characterName: $name
    )
}
