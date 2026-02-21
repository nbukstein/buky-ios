import Foundation
import StoreKit

@MainActor
final class SubscriptionViewModel: ObservableObject {

    private let subscriptionManager = SubscriptionManager.shared

    @Published var selectedProductID: String?
    @Published var isPurchasing = false

    var products: [BukyProduct] {
        subscriptionManager.products.map { product in
            let discount: String? = product.id == SubscriptionManager.ProductID.yearly.rawValue
                ? String(localized: "Save 33%", comment: "Yearly discount badge")
                : nil
            return BukyProduct(from: product, discountText: discount)
        }
    }

    var monthlyProduct: BukyProduct? {
        guard let product = subscriptionManager.monthlyProduct else { return nil }
        return BukyProduct(from: product)
    }

    var yearlyProduct: BukyProduct? {
        guard let product = subscriptionManager.yearlyProduct else { return nil }
        return BukyProduct(from: product, discountText: String(localized: "Save 33%", comment: "Yearly discount badge"))
    }

    var isSubscribed: Bool {
        subscriptionManager.isSubscribed
    }

    var hasSelection: Bool {
        selectedProductID != nil
    }

    var errorMessage: String? {
        get { subscriptionManager.errorMessage }
        set { subscriptionManager.errorMessage = newValue }
    }

    init() {
        selectDefaultProduct()
    }

    func purchase() async {
        guard let id = selectedProductID,
              let product = subscriptionManager.products.first(where: { $0.id == id }) else { return }

        isPurchasing = true
        do {
            try await subscriptionManager.purchase(product)
        } catch {
            subscriptionManager.errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    private func selectDefaultProduct() {
        if let last = subscriptionManager.products.last {
            selectedProductID = last.id
        }
    }
}
