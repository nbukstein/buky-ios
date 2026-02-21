import Foundation
import RevenueCat

@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    // MARK: - Product IDs

    enum ProductID: String, CaseIterable {
        case monthly = "monthly"
        case yearly = "yearly"
    }

    // MARK: - Published State

    @Published private(set) var products: [Package] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Computed Properties

    var isSubscribed: Bool {
        !purchasedProductIDs.isEmpty
    }

    var currentSubscriptionTier: ProductID? {
        for id in ProductID.allCases where purchasedProductIDs.contains(id.rawValue) {
            return id
        }
        return nil
    }

    var monthlyProduct: Package? {
        products.first { $0.storeProduct.productIdentifier == ProductID.monthly.rawValue }
    }

    var yearlyProduct: Package? {
        products.first { $0.storeProduct.productIdentifier == ProductID.yearly.rawValue }
    }

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init

    private init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Fetch Products

    func fetchProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current {
                products = current.availablePackages.sorted {
                    $0.storeProduct.price < $1.storeProduct.price
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase(_ package: Package) async throws -> StoreTransaction? {
        let (transaction, _, userCancelled) = try await Purchases.shared.purchase(package: package)

        if userCancelled { return nil }

        await updatePurchasedProducts()
        return transaction
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await Purchases.shared.restorePurchases()
            await updatePurchasedProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Check Subscription Status

    /// Checks whether the user has an active subscription via RevenueCat.
    /// Throws if RevenueCat cannot be reached.
    func checkSubscriptionStatus() async throws -> Bool {
        await updatePurchasedProducts()
        return isSubscribed
    }

    // MARK: - Update Purchased Products

    func updatePurchasedProducts() async {
        let previousTier = currentSubscriptionTier

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            purchasedProductIDs = customerInfo.activeSubscriptions
        } catch {
            errorMessage = error.localizedDescription
        }

        let newTier = currentSubscriptionTier
        if newTier != previousTier {
            StoryLimitManager.shared.onSubscriptionChanged(tier: newTier)
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await _ in Purchases.shared.customerInfoStream {
                await self?.updatePurchasedProducts()
            }
        }
    }
}
