import SwiftUI

struct GridChipsView: View {
    
    let story: Story
    
    private let adaptiveColumns = [GridItem(.flexible(minimum: .zero, maximum: .infinity)),GridItem(.flexible(minimum: .zero, maximum: .infinity))]
    
    init(story: Story) {
        self.story = story
    }
    
    var body: some View {
        HorizontalFlowLayout(spacing: 5, rowSpacing: 5) {
            makeChip(icon: AgeSectionView.Constants.titleIcon, info: story.childAge?.ageRange ?? "", color: AgeSectionView.Constants.color)
            makeChip(icon: StoryLengthSectionView.Constants.titleIcon, info: story.storyTimeLength?.timeRange ?? "", color: StoryLengthSectionView.Constants.color)
            makeChip(icon: PlaceSectionView.Constants.titleIcon, info: story.place?.title ?? "", color: PlaceSectionView.Constants.color)
            makeChip(icon: "", image: Image(.people), info: story.characters.map {$0.title}.joined(separator: " - "), color: ProtagonistsSectionView.Constants.color)
            makeChip(icon: LessonsSectionView.Constants.titleIcon, info: story.lesson?.title ?? "", color: LessonsSectionView.Constants.color)
            makeChip(icon: AIProviderSectionView.Constants.titleIcon, info: story.provider?.title ?? "", color: AIProviderSectionView.Constants.color)
            if let animalType = story.animalType {
                let info = [animalType.title, story.animalName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " - ")
                makeChip(icon: CharacterNameSectionView.chipIcon, info: info, color: CharacterNameSectionView.color)
            }
            if let personType = story.personType {
                let info = [personType.title, story.personName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " - ")
                makeChip(icon: CharacterNameSectionView.chipIcon, info: info, color: CharacterNameSectionView.color)
            }
        }
    }

    @ViewBuilder
    private func makeChip(icon: String, image: Image? = nil, info: String, color: Color) -> some View {
        HStack {
            if let image {
                image
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                    .clipShape(.circle)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                    .clipShape(.circle)
            }
            Text(info)
                .font(.captionRegular)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: 200)
    }
}

// Vista personalizada para layout tipo "flow" horizontal
struct HorizontalFlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = computeLayout(proposal: proposal, subviews: subviews)
        
        for (index, position) in layout.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(layout.sizes[index])
            )
        }
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint], sizes: [CGSize]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            // Si el elemento no cabe en la fila actual, pasar a la siguiente
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + rowSpacing
                rowHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + rowHeight
        }
        
        return (CGSize(width: totalWidth, height: totalHeight), positions, sizes)
    }
}

#Preview {
    GridChipsView(story: .init(text: "", dateCreated: Date(), childAge: .fiveSeven, storyTimeLength: .long, place: .city, characters: [.animals, .dragons], lesson: .empathy, language: "", provider: .claude))
}

