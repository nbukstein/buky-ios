import SwiftUI

struct PlanCardView: View {

    let product: BukyProduct
    @Binding var selectedProductID: String?

    private var isSelected: Bool {
        selectedProductID == product.id
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedProductID = product.id
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading){
                    Text(product.period)
                        .font(.h4SemiBold)
                        .foregroundStyle(.white)
                    
                    Text(product.price)
                        .font(.h4SemiBold)
                        .foregroundStyle(.white)
//                    Spacer(minLength: 30)
                    if let discountText = product.discountText {
                        Text(discountText)
                            .font(.h5Bold)
                            .foregroundStyle(Color.cuarterlyBrand)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.white))
                    }
                    Spacer(minLength: 40)
                    Text(product.billedText)
                        .font(.bodyRegular)
                        .foregroundStyle(.white.opacity(0.8))
                }
                ZStack {
                    Circle()
                        .strokeBorder(.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.cuarterlyBrand)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(isSelected ? 0.25 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 60)
    }
}


#Preview {
    @Previewable @State var selectedProductID: String? = ""
    @Previewable @State var selectedProductID2: String? = nil
    
    HStack {
        PlanCardView(product: .init(id: "", name: "Monthly", price: "3,99", period: "Monthly", discountText: nil, billedText: "Billet monthly"), selectedProductID: $selectedProductID)
        PlanCardView(product: .init(id: "", name: "Yarly", price: "3,99", period: "Monthly", discountText: "20%", billedText: "Billet yearly"), selectedProductID: $selectedProductID2)
    }
}
