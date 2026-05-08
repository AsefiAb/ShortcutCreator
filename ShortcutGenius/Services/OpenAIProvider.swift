import Foundation

struct OpenAIProvider: AIProvider {
    let apiKey: String
    var model: String = "gpt-4o-mini"

    private static let systemPrompt = """
    You are a generator for the iOS Shortcuts app. Given a user idea, output a STRICT JSON object describing one shortcut. Use only Shortcuts action identifiers from this allow-list (these mirror our built-in templates):
    - is.workflow.actions.dnd.set
    - is.workflow.actions.url
    - is.workflow.actions.playmusic
    - is.workflow.actions.playpodcast
    - is.workflow.actions.searchlocally
    - is.workflow.actions.sendmessage
    - is.workflow.actions.callcontact
    - is.workflow.actions.appendnote
    - is.workflow.actions.notes.create
    - is.workflow.actions.calendar.add
    - is.workflow.actions.calendar.todayevents
    - is.workflow.actions.calendar.events
    - is.workflow.actions.reminders.add
    - is.workflow.actions.reminders.list
    - is.workflow.actions.timer.start
    - is.workflow.actions.recordaudio
    - is.workflow.actions.weather.current
    - is.workflow.actions.weather.gettraffic
    - is.workflow.actions.lowpowermode.set
    - is.workflow.actions.airplane.set
    - is.workflow.actions.hotspot.toggle
    - is.workflow.actions.brightness.set
    - is.workflow.actions.location.current
    - is.workflow.actions.location.share
    - is.workflow.actions.home.scene
    - is.workflow.actions.home.toggle
    - is.workflow.actions.home.intercom
    - is.workflow.actions.home.status
    - is.workflow.actions.home.camera
    - is.workflow.actions.workout.start
    - is.workflow.actions.health.steps
    - is.workflow.actions.health.heartrate
    - is.workflow.actions.health.mood
    - is.workflow.actions.health.log
    - is.workflow.actions.image.color
    - is.workflow.actions.image.resize
    - is.workflow.actions.image.removebg
    - is.workflow.actions.image.gif
    - is.workflow.actions.video.trim
    - is.workflow.actions.pdf.create
    - is.workflow.actions.qr.scan
    - is.workflow.actions.qr.generate
    - is.workflow.actions.calc
    - is.workflow.actions.text.speak
    - is.workflow.actions.translate.text
    - is.workflow.actions.clipboard.set
    - is.workflow.actions.mail.compose
    - is.workflow.actions.mail.inbox
    - is.workflow.actions.wallet.open
    - is.workflow.actions.camera.open
    - is.workflow.actions.screen.time.toggle
    - is.workflow.actions.device.battery
    - is.workflow.actions.date.timezone
    - is.workflow.actions.photos.latest
    - is.workflow.actions.file.createfolder

    Output schema:
    {
      "title": "string (max 32 chars)",
      "summary": "string (max 90 chars, plain English)",
      "category": "driving|focus|family|work|health|smartHome|travel|productivity|creative|wellness",
      "icon": "SF Symbol name",
      "colorHex": "#RRGGBB",
      "actions": [{ "identifier": "is.workflow.actions.X", "displayName": "string", "parameters": {"key":"value"} }],
      "conversational": "1-2 friendly sentences explaining the shortcut"
    }

    Return ONLY the JSON. No markdown fences, no commentary.
    """

    func generate(from prompt: String, history: [ChatTurn]) async throws -> AIShortcutResponse {
        var messages: [[String: Any]] = [
            ["role": "system", "content": Self.systemPrompt]
        ]
        for turn in history.suffix(6) {
            messages.append(["role": turn.role, "content": turn.content])
        }
        messages.append(["role": "user", "content": prompt])

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "response_format": ["type": "json_object"],
            "temperature": 0.4
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
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
        guard let json = envelope.choices.first?.message.content,
              let payload = json.data(using: .utf8) else {
            throw AIService.ServiceError.decodingFailed
        }
        return try ProviderDecoder.decode(payload)
    }
}

enum ProviderDecoder {
    struct Raw: Decodable {
        let title: String
        let summary: String
        let category: String
        let icon: String
        let colorHex: String
        let actions: [RawAction]
        let conversational: String
    }
    struct RawAction: Decodable {
        let identifier: String
        let displayName: String
        let parameters: [String: String]?
    }

    static func decode(_ data: Data) throws -> AIShortcutResponse {
        let raw = try JSONDecoder().decode(Raw.self, from: data)
        let category = ShortcutCategory(rawValue: raw.category) ?? .productivity
        return AIShortcutResponse(
            title: String(raw.title.prefix(40)),
            summary: String(raw.summary.prefix(120)),
            category: category,
            icon: raw.icon,
            colorHex: raw.colorHex,
            actions: raw.actions.map {
                AIAction(identifier: $0.identifier,
                         displayName: $0.displayName,
                         parameters: $0.parameters ?? [:])
            },
            conversational: raw.conversational
        )
    }
}
