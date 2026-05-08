import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// Audit fix: HapticsManager v1 imported UIKit unconditionally — broke the
// macOS build. Now platform-conditional with NSHapticFeedbackManager fallback.
@MainActor
final class HapticsManager {
    #if canImport(UIKit) && !os(watchOS)
    private let selection = UISelectionFeedbackGenerator()
    private let success = UINotificationFeedbackGenerator()
    private let impact = UIImpactFeedbackGenerator(style: .soft)
    #endif

    func tap() {
        #if canImport(UIKit) && !os(watchOS)
        selection.selectionChanged()
        #elseif canImport(AppKit)
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        #endif
    }

    func celebrate() {
        #if canImport(UIKit) && !os(watchOS)
        success.notificationOccurred(.success)
        #elseif canImport(AppKit)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }

    func bump() {
        #if canImport(UIKit) && !os(watchOS)
        impact.impactOccurred()
        #elseif canImport(AppKit)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }
}
