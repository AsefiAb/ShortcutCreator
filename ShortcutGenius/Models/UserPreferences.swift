import Foundation
import Observation

@Observable
@MainActor
final class UserPreferences {
    var preferredProvider: AIProviderKind {
        get { AIProviderKind(rawValue: UserDefaults.standard.string(forKey: "ai.provider") ?? "openai") ?? .openai }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "ai.provider") }
    }

    var hapticsEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "haptics.enabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "haptics.enabled") }
    }

    var showsLiquidGlass: Bool {
        get { UserDefaults.standard.object(forKey: "ui.liquidGlass") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "ui.liquidGlass") }
    }

    var dailyBriefEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "dailyBrief.enabled") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "dailyBrief.enabled") }
    }
}

enum AIProviderKind: String, CaseIterable, Identifiable {
    case openai
    case grok
    case onDeviceOnly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openai: return "OpenAI (your key)"
        case .grok: return "Grok / xAI (your key)"
        case .onDeviceOnly: return "On-device only"
        }
    }

    var keychainKey: String {
        switch self {
        case .openai: return "apiKey.openai"
        case .grok: return "apiKey.grok"
        case .onDeviceOnly: return ""
        }
    }
}
