import Foundation

// Anthropic Claude provider — uses the Messages API with structured output.
// API key is read from the Keychain (saved via Settings) or — for CI / dev
// builds — from the ANTHROPIC_API_KEY environment variable. Never commit
// the key. See docs/SECRETS.md for the secure-handling guide.
struct AnthropicProvider: AIProvider {
    let apiKey: String
    var model: String

    init(apiKey: String, model: String = "claude-opus-4-7") {
        self.apiKey = apiKey
        self.model = model
    }

    private static let systemPrompt = """
    You are a generator for the iOS Shortcuts app. Given a user idea, output a single JSON object only — no markdown, no commentary — describing one shortcut.

    Schema:
    {
      "title": string (max 32 chars),
      "summary": string (max 90 chars, plain English),
      "category": "driving"|"focus"|"family"|"work"|"health"|"smartHome"|"travel"|"productivity"|"creative"|"wellness",
      "icon": string (SF Symbol name),
      "colorHex": string (#RRGGBB),
      "actions": [{ "identifier": "is.workflow.actions.X", "displayName": string, "parameters": {string: string} }],
      "conversational": string (1-2 friendly sentences explaining the shortcut)
    }

    Use only is.workflow.actions.* identifiers from this list (these mirror our built-in templates):
    is.workflow.actions.dnd.set, is.workflow.actions.url, is.workflow.actions.playmusic, is.workflow.actions.playpodcast, is.workflow.actions.searchlocally, is.workflow.actions.sendmessage, is.workflow.actions.callcontact, is.workflow.actions.appendnote, is.workflow.actions.notes.create, is.workflow.actions.calendar.add, is.workflow.actions.calendar.todayevents, is.workflow.actions.calendar.events, is.workflow.actions.reminders.add, is.workflow.actions.reminders.list, is.workflow.actions.timer.start, is.workflow.actions.recordaudio, is.workflow.actions.weather.current, is.workflow.actions.weather.gettraffic, is.workflow.actions.lowpowermode.set, is.workflow.actions.airplane.set, is.workflow.actions.hotspot.toggle, is.workflow.actions.brightness.set, is.workflow.actions.location.current, is.workflow.actions.location.share, is.workflow.actions.home.scene, is.workflow.actions.home.toggle, is.workflow.actions.home.intercom, is.workflow.actions.home.status, is.workflow.actions.home.camera, is.workflow.actions.workout.start, is.workflow.actions.health.steps, is.workflow.actions.health.heartrate, is.workflow.actions.health.mood, is.workflow.actions.health.log, is.workflow.actions.image.color, is.workflow.actions.image.resize, is.workflow.actions.image.removebg, is.workflow.actions.image.gif, is.workflow.actions.video.trim, is.workflow.actions.pdf.create, is.workflow.actions.qr.scan, is.workflow.actions.qr.generate, is.workflow.actions.calc, is.workflow.actions.text.speak, is.workflow.actions.translate.text, is.workflow.actions.clipboard.set, is.workflow.actions.mail.compose, is.workflow.actions.mail.inbox, is.workflow.actions.wallet.open, is.workflow.actions.camera.open, is.workflow.actions.screen.time.toggle, is.workflow.actions.device.battery, is.workflow.actions.date.timezone, is.workflow.actions.photos.latest, is.workflow.actions.file.createfolder.

    Return ONLY the JSON.
    """

    func generate(from prompt: String, history: [ChatTurn]) async throws -> AIShortcutResponse {
        var messages: [[String: Any]] = []
        for turn in history.suffix(6) where turn.role != "system" {
            messages.append(["role": turn.role, "content": turn.content])
        }
        messages.append(["role": "user", "content": prompt])

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": Self.systemPrompt,
            "messages": messages,
            "temperature": 0.4
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Anthropic request failed"
            throw AIService.ServiceError.providerError(msg)
        }

        struct Envelope: Decodable {
            struct Block: Decodable { let type: String; let text: String? }
            let content: [Block]
        }

        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        let text = envelope.content.compactMap { $0.text }.joined()
        let cleaned = stripCodeFences(text)
        guard let payload = cleaned.data(using: .utf8) else {
            throw AIService.ServiceError.decodingFailed
        }
        return try ProviderDecoder.decode(payload)
    }

    private func stripCodeFences(_ s: String) -> String {
        var out = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if out.hasPrefix("```") {
            out = out.replacingOccurrences(of: "```json", with: "")
            out = out.replacingOccurrences(of: "```", with: "")
        }
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Resolve a key in priority order: keychain (user-typed) → process env var
// (CI / local dev) → nil. Used by AIService.
enum APIKeyResolver {
    static func resolve(_ kind: AIProviderKind) -> String? {
        if let stored = KeychainStore.read(forKey: kind.keychainKey), !stored.isEmpty {
            return stored
        }
        let envName: String
        switch kind {
        case .anthropic: envName = "ANTHROPIC_API_KEY"
        case .openai: envName = "OPENAI_API_KEY"
        case .grok: envName = "XAI_API_KEY"
        case .onDeviceOnly: return nil
        }
        if let env = ProcessInfo.processInfo.environment[envName], !env.isEmpty {
            return env
        }
        return nil
    }
}
