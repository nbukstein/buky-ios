import Foundation
import RevenueCat

@MainActor
final class SubscriptionViewModel: ObservableObject {

    private let subscriptionManager = SubscriptionManager.shared

    @Published var selectedProductID: String?
    @Published var isPurchasing = false

    var products: [BukyProduct] {
        subscriptionManager.products.map { package in
            let discount: String? = package.storeProduct.productIdentifier == SubscriptionManager.ProductID.yearly.rawValue
                ? String(localized: "Save 33%", comment: "Yearly discount badge")
                : nil
            return BukyProduct(from: package, discountText: discount)
        }
    }

    var monthlyProduct: BukyProduct? {
        guard let package = subscriptionManager.monthlyProduct else { return nil }
        return BukyProduct(from: package)
    }

    var yearlyProduct: BukyProduct? {
        guard let package = subscriptionManager.yearlyProduct else { return nil }
        return BukyProduct(from: package, discountText: String(localized: "Save 33%", comment: "Yearly discount badge"))
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
              let package = subscriptionManager.products.first(where: { $0.storeProduct.productIdentifier == id }) else { return }

        isPurchasing = true
        do {
            try await subscriptionManager.purchase(package)
        } catch {
            subscriptionManager.errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    private func selectDefaultProduct() {
        if let last = subscriptionManager.products.last {
            selectedProductID = last.storeProduct.productIdentifier
        }
    }
}
