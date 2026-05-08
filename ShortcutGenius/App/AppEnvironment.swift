import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class AppEnvironment {
    var entitlements = EntitlementManager()
    var aiService = AIService()
    var installer = ShortcutInstaller()
    var speech = SpeechRecognizer()
    var store = StoreManager()
    var haptics = HapticsManager()
    var preferences = UserPreferences()

    private(set) var isBootstrapped = false

    func bootstrap(container: ModelContainer) async {
        guard !isBootstrapped else { return }
        isBootstrapped = true
        await store.loadProducts()
        await entitlements.refresh(from: store)
        aiService.configure(preferences: preferences)
    }
}
