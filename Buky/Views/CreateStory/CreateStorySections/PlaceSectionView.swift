import SwiftUI

struct PlaceSectionView: View {
    
    enum Constants {
        static let title = String(localized: "Where do you want your story to happen?", comment: "Title for the place section")
        static let color = Color.savedColorOne
        static let titleIcon = "map"
    }
    
    @Binding var indexSelected: Int?
    
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
        LazyVGrid(columns: adapriveColumns, spacing: 20){
            ForEach(Array(Story.Place.allCases.enumerated()), id: \.offset) { index, option in
                makeOptionItem(
                    item: option,
                    index: index
                )
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func makeOptionItem(item: Story.Place, index: Int) -> some View {
        let isSelected = index == indexSelected
        let opacity = isSelected ? 0.2 : 0
        Button(action: {
            Task { @MainActor in
                indexSelected = index
            }
        }) {
            VStack {
                if let image = item.specialIcon {
                    image
                        .resizable()     
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Constants.color)
                        .padding()
                    .background(Constants.color.opacity(0.3))
                    .clipShape(Circle())
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Constants.color)
                        .padding()
                        .background(Constants.color.opacity(0.3))
                        .clipShape(Circle())
                }
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

extension Story.Place {
    
    var title: String {
        switch self {
        case .mountain: String(localized: "Mountain", comment: "Title for mountain")
        case .castlle: String(localized: "Castlle", comment: "Title for castlle")
        case .woods: String(localized: "Woods", comment: "Title for woods")
        case .sea: String(localized: "Sea", comment: "Title for sea")
        case .river: String(localized: "River", comment: "Title for river")
        case .space: String(localized: "Space", comment: "Title for space")
        case .house: String(localized: "House", comment: "Title for house")
        case .city: String(localized: "City", comment: "Title for city")
        }
    }

    var icon: String {
        switch self {
        case .mountain: "mountain.2"
        case .castlle: "building.columns.fill"
        case .woods: "tree.fill"
        case .sea: "water.waves"
        case .river: "leaf.fill"
        case .space: "rocket.fill"
        case .house: "house.fill"
        case .city: "building.2.fill"
        }
    }

    var specialIcon: Image? {
        switch self {
        case .space: Image(.rocket)
        default: nil
        }
    }
}

#Preview {
    @Previewable @State var indexSelected: Int? = 0
    PlaceSectionView(indexSelected: $indexSelected)
}
