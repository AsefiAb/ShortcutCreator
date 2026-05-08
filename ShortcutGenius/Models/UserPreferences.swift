import Foundation
import Observation

// Audit fix: v1 backed properties directly with UserDefaults reads, which
// bypassed @Observable change tracking — bindings derived from these never
// updated views. Now we keep stored backing properties (so @Observable
// tracks them) and persist on didSet.
@Observable
@MainActor
final class UserPreferences {
    var preferredProvider: AIProviderKind {
        didSet { defaults.set(preferredProvider.rawValue, forKey: Keys.provider) }
    }

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.haptics) }
    }

    var showsLiquidGlass: Bool {
        didSet { defaults.set(showsLiquidGlass, forKey: Keys.glass) }
    }

    var dailyBriefEnabled: Bool {
        didSet { defaults.set(dailyBriefEnabled, forKey: Keys.dailyBrief) }
    }

    var preferredAnthropicModel: String {
        didSet { defaults.set(preferredAnthropicModel, forKey: Keys.anthropicModel) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let provider = "ai.provider"
        static let haptics = "haptics.enabled"
        static let glass = "ui.liquidGlass"
        static let dailyBrief = "dailyBrief.enabled"
        static let anthropicModel = "ai.anthropic.model"
    }

    init() {
        let raw = defaults.string(forKey: Keys.provider) ?? AIProviderKind.anthropic.rawValue
        self.preferredProvider = AIProviderKind(rawValue: raw) ?? .anthropic
        self.hapticsEnabled = defaults.object(forKey: Keys.haptics) as? Bool ?? true
        self.showsLiquidGlass = defaults.object(forKey: Keys.glass) as? Bool ?? true
        self.dailyBriefEnabled = defaults.object(forKey: Keys.dailyBrief) as? Bool ?? false
        self.preferredAnthropicModel = defaults.string(forKey: Keys.anthropicModel) ?? "claude-opus-4-7"
    }
}

enum AIProviderKind: String, CaseIterable, Identifiable, Sendable {
    case anthropic
    case openai
    case grok
    case onDeviceOnly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anthropic: return "Claude (your key)"
        case .openai: return "OpenAI (your key)"
        case .grok: return "Grok / xAI (your key)"
        case .onDeviceOnly: return "On-device only"
        }
    }

    var keychainKey: String {
        switch self {
        case .anthropic: return "apiKey.anthropic"
        case .openai: return "apiKey.openai"
        case .grok: return "apiKey.grok"
        case .onDeviceOnly: return ""
        }
    }

    var requiresKey: Bool { self != .onDeviceOnly }
}
