import Foundation
import Observation

protocol AIProvider: Sendable {
    func generate(from prompt: String, history: [ChatTurn]) async throws -> AIShortcutResponse
}

struct ChatTurn: Sendable {
    let role: String
    let content: String
}

struct AIShortcutResponse: Sendable {
    let title: String
    let summary: String
    let category: ShortcutCategory
    let icon: String
    let colorHex: String
    let actions: [AIAction]
    let conversational: String
}

struct AIAction: Sendable {
    let identifier: String
    let displayName: String
    let parameters: [String: String]
}

@Observable
@MainActor
final class AIService {
    enum ServiceError: LocalizedError {
        case missingAPIKey
        case rateLimited
        case decodingFailed
        case providerError(String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Add your API key in Settings to use cloud generation."
            case .rateLimited: return "You've hit your monthly free limit. Upgrade to keep going."
            case .decodingFailed: return "The AI returned a response we couldn't parse."
            case .providerError(let m): return m
            }
        }
    }

    private(set) var isGenerating = false
    private weak var preferences: UserPreferences?

    func configure(preferences: UserPreferences) {
        self.preferences = preferences
    }

    func generate(prompt: String, history: [ChatTurn] = []) async throws -> AIShortcutResponse {
        isGenerating = true
        defer { isGenerating = false }

        let kind = preferences?.preferredProvider ?? .onDeviceOnly

        switch kind {
        case .openai:
            let key = KeychainStore.read(forKey: kind.keychainKey) ?? ""
            guard !key.isEmpty else { throw ServiceError.missingAPIKey }
            return try await OpenAIProvider(apiKey: key).generate(from: prompt, history: history)
        case .grok:
            let key = KeychainStore.read(forKey: kind.keychainKey) ?? ""
            guard !key.isEmpty else { throw ServiceError.missingAPIKey }
            return try await GrokProvider(apiKey: key).generate(from: prompt, history: history)
        case .onDeviceOnly:
            return OnDeviceProvider().generate(from: prompt)
        }
    }
}

// Built-in heuristic generator. Used when the user has no API key set.
// Pattern-matches the prompt to an existing example so first-run is useful
// without any cloud calls.
struct OnDeviceProvider {
    func generate(from prompt: String) -> AIShortcutResponse {
        let lower = prompt.lowercased()

        let scored = ExampleShortcuts.all.map { example -> (ExampleShortcut, Int) in
            let title = example.title.lowercased()
            let summary = example.summary.lowercased()
            var score = 0
            for token in lower.split(separator: " ") where token.count > 2 {
                if title.contains(token) { score += 3 }
                if summary.contains(token) { score += 1 }
            }
            return (example, score)
        }

        let best = scored.max { $0.1 < $1.1 }?.0 ?? ExampleShortcuts.all[0]

        return AIShortcutResponse(
            title: best.title,
            summary: best.summary,
            category: best.category,
            icon: best.icon,
            colorHex: best.colorHex,
            actions: best.actions.map {
                AIAction(identifier: $0.identifier, displayName: $0.displayName, parameters: $0.parameters)
            },
            conversational: "I matched your idea to the closest built-in shortcut: \(best.title). Add an OpenAI or Grok key in Settings for fully custom generations."
        )
    }
}
