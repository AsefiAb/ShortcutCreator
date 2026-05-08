import UIKit

@MainActor
final class HapticsManager {
    private let selection = UISelectionFeedbackGenerator()
    private let success = UINotificationFeedbackGenerator()
    private let impact = UIImpactFeedbackGenerator(style: .soft)

    func tap() {
        selection.selectionChanged()
    }

    func celebrate() {
        success.notificationOccurred(.success)
    }

    func bump() {
        impact.impactOccurred()
    }
}
