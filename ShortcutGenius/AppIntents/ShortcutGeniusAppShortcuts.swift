import AppIntents
import SwiftUI

// App Intents path: this exposes our shortcuts as native AppShortcuts so
// they appear automatically in the Shortcuts app — no "Allow Untrusted
// Shortcuts" toggle required, App Store-friendly.

struct OpenCreateScreenIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Create Screen"
    static var description = IntentDescription("Opens the Shortcut Genius idea-to-shortcut creator.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct GenerateFromIdeaIntent: AppIntent {
    static var title: LocalizedStringResource = "Generate Shortcut From Idea"
    static var description = IntentDescription("Describe a shortcut idea and have it generated.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Your idea")
    var idea: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        DeepLinkRouter.shared.deepLink(.create(prompt: idea))
        return .result(dialog: "Opening Shortcut Genius and generating from your idea.")
    }
}

struct OpenLibraryIntent: AppIntent {
    static var title: LocalizedStringResource = "Open My Shortcuts Library"
    static var description = IntentDescription("Browse shortcuts you've created.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct ShortcutGeniusAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GenerateFromIdeaIntent(),
            phrases: [
                "Make a shortcut with \(.applicationName)",
                "Create a shortcut in \(.applicationName)",
                "Ask \(.applicationName) to build a shortcut"
            ],
            shortTitle: "Generate Shortcut",
            systemImageName: "wand.and.stars"
        )
        AppShortcut(
            intent: OpenCreateScreenIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)"
            ],
            shortTitle: "Open Genius",
            systemImageName: "sparkles"
        )
        AppShortcut(
            intent: OpenLibraryIntent(),
            phrases: ["Show my \(.applicationName) library"],
            shortTitle: "My Library",
            systemImageName: "square.stack.3d.up"
        )
    }
}

@MainActor
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    private init() {}

    enum Destination: Equatable {
        case create(prompt: String)
        case library
    }

    var pending: Destination?
    var listeners: [(Destination) -> Void] = []

    func deepLink(_ destination: Destination) {
        pending = destination
        listeners.forEach { $0(destination) }
    }
}
