import Foundation
import Observation

@Observable
@MainActor
final class EntitlementManager {
    static let monthlyFreeQuota = 10

    var isPremium: Bool = false
    var lifetimeUnlocked: Bool = false
    var monthlyGenerationsUsed: Int = 0

    var remainingMonthlyGenerations: Int {
        max(0, Self.monthlyFreeQuota - monthlyGenerationsUsed)
    }

    var canGenerate: Bool {
        isPremium || lifetimeUnlocked || remainingMonthlyGenerations > 0
    }

    func refresh(from store: StoreManager) async {
        isPremium = store.hasActiveSubscription
        lifetimeUnlocked = store.hasLifetime
    }

    func recordGeneration() {
        monthlyGenerationsUsed += 1
    }
}
