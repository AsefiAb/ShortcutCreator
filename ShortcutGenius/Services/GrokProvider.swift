import Foundation

struct GrokProvider: AIProvider {
    let apiKey: String
    var model: String = "grok-2-latest"

    func generate(from prompt: String, history: [ChatTurn]) async throws -> AIShortcutResponse {
        var messages: [[String: Any]] = [
            ["role": "system", "content": grokSystemPrompt]
        ]
        for turn in history.suffix(6) {
            messages.append(["role": turn.role, "content": turn.content])
        }
        messages.append(["role": "user", "content": prompt])

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.4
        ]

        var request = URLRequest(url: URL(string: "https://api.x.ai/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Request failed"
            throw AIService.ServiceError.providerError(msg)
        }

        struct Envelope: Decodable {
            struct Choice: Decodable {
                struct Msg: Decodable { let content: String }
                let message: Msg
            }
            let choices: [Choice]
        }

        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        guard let raw = envelope.choices.first?.message.content else {
            throw AIService.ServiceError.decodingFailed
        }
        let cleaned = stripCodeFences(raw)
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

private let grokSystemPrompt = """
You are a generator for the iOS Shortcuts app. Output a single JSON object only — no commentary, no markdown — with this schema:
{
  "title": "string",
  "summary": "string",
  "category": "driving|focus|family|work|health|smartHome|travel|productivity|creative|wellness",
  "icon": "SF Symbol name",
  "colorHex": "#RRGGBB",
  "actions": [{"identifier": "is.workflow.actions.X", "displayName": "string", "parameters": {"k":"v"}}],
  "conversational": "string"
}
Use only is.workflow.actions.* identifiers that exist in iOS 18 Shortcuts.
"""
