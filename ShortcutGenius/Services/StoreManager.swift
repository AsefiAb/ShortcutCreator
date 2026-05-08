import Foundation
import StoreKit
import Observation

@Observable
@MainActor
final class StoreManager {
    enum ProductID: String, CaseIterable {
        case yearly = "com.shortcutgenius.premium.yearly"
        case lifetime = "com.shortcutgenius.premium.lifetime"
        case tipSmall = "com.shortcutgenius.tip.coffee"
    }

    private(set) var products: [Product] = []
    private(set) var purchasedIDs: Set<String> = []
    private(set) var isLoading = false

    var hasActiveSubscription: Bool {
        purchasedIDs.contains(ProductID.yearly.rawValue)
    }

    var hasLifetime: Bool {
        purchasedIDs.contains(ProductID.lifetime.rawValue)
    }

    var yearlyProduct: Product? { products.first { $0.id == ProductID.yearly.rawValue } }
    var lifetimeProduct: Product? { products.first { $0.id == ProductID.lifetime.rawValue } }
    var tipProduct: Product? { products.first { $0.id == ProductID.tipSmall.rawValue } }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = Task.detached { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await self?.markPurchased(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    deinit { transactionListener?.cancel() }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = ProductID.allCases.map(\.rawValue)
            products = try await Product.products(for: ids)
            await refreshEntitlements()
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let txn) = verification {
                markPurchased(txn)
                await txn.finish()
                return true
            }
            return false
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result {
                owned.insert(t.productID)
            }
        }
        purchasedIDs = owned
    }

    private func markPurchased(_ transaction: Transaction) {
        purchasedIDs.insert(transaction.productID)
    }
}
