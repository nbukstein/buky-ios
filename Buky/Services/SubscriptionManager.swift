import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    // MARK: - Product IDs

    enum ProductID: String, CaseIterable {
        case monthly = "com.buky.monthly"
        case yearly = "com.buky.yearly"
    }

    // MARK: - Published State

    @Published private(set) var products: [Product] = []
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

    var monthlyProduct: Product? {
        products.first { $0.id == ProductID.monthly.rawValue }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == ProductID.yearly.rawValue }
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
            let ids = ProductID.allCases.map(\.rawValue)
            products = try await Product.products(for: ids)
                .sorted { $0.price < $1.price }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Check Subscription Status

    /// Checks whether the user has an active subscription by syncing with the App Store.
    /// Throws if the App Store cannot be reached.
    func checkSubscriptionStatus() async throws -> Bool {
        try await AppStore.sync()
        await updatePurchasedProducts()
        return isSubscribed
    }

    // MARK: - Update Purchased Products

    func updatePurchasedProducts() async {
        let previousTier = currentSubscriptionTier
        var purchased: Set<String> = []

        for await result in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchased

        let newTier = currentSubscriptionTier
        if newTier != previousTier {
            StoryLimitManager.shared.onSubscriptionChanged(tier: newTier)
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                if let transaction = try? await self?.checkVerified(result) {
                    await self?.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }
}

// MARK: - Errors

extension SubscriptionManager {
    enum StoreError: LocalizedError {
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "Transaction verification failed."
            }
        }
    }
}
