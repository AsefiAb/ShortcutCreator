import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var messages: [ChatMessage]
    @State private var draft = ""
    @State private var showingPaywall = false
    @State private var generatedPreview: AIShortcutResponse?

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                if messages.isEmpty { EmptyState() }
                                ForEach(messages) { msg in
                                    ChatBubble(message: msg)
                                        .id(msg.id)
                                }
                                if let generatedPreview {
                                    GeneratedPreviewCard(response: generatedPreview) {
                                        Task { await install(generatedPreview) }
                                    } onSave: {
                                        save(generatedPreview)
                                    }
                                }
                                if env.aiService.isGenerating { ThinkingDots() }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    InputBar(
                        text: $draft,
                        isRecording: env.speech.isRecording,
                        onSend: { send() },
                        onMic: { Task { await toggleMic() } }
                    )
                }
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPaywall) { PaywallView() }
        }
    }

    private func send() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        env.haptics.tap()

        if !env.entitlements.canGenerate {
            showingPaywall = true
            return
        }

        let userMsg = ChatMessage(role: .user, content: prompt)
        modelContext.insert(userMsg)
        try? modelContext.save()
        draft = ""

        Task {
            do {
                let history = messages.suffix(8).map { ChatTurn(role: $0.role.rawValue, content: $0.content) }
                let response = try await env.aiService.generate(prompt: prompt, history: history)
                generatedPreview = response
                let assistantMsg = ChatMessage(role: .assistant, content: response.conversational)
                modelContext.insert(assistantMsg)
                modelContext.insert(UsageRecord(kind: "ai_generation"))
                env.entitlements.recordGeneration()
                try? modelContext.save()
                env.haptics.celebrate()
            } catch {
                let assistantMsg = ChatMessage(role: .assistant, content: error.localizedDescription)
                modelContext.insert(assistantMsg)
                try? modelContext.save()
            }
        }
    }

    private func toggleMic() async {
        if env.speech.isRecording {
            env.speech.stop()
            draft = env.speech.transcript
            return
        }
        if env.speech.authState != .authorized {
            await env.speech.requestAuthorization()
        }
        guard env.speech.authState == .authorized else { return }
        try? env.speech.start()
    }

    private func save(_ response: AIShortcutResponse) {
        let actions = response.actions.enumerated().map { idx, a in
            ShortcutAction(
                order: idx,
                actionIdentifier: a.identifier,
                displayName: a.displayName,
                parameters: a.parameters.mapValues { $0 as AnyHashable }
            )
        }
        let shortcut = UserShortcut(
            title: response.title,
            summary: response.summary,
            category: response.category,
            iconSystemName: response.icon,
            colorHex: response.colorHex,
            promptSource: messages.last?.content,
            actions: actions
        )
        modelContext.insert(shortcut)
        try? modelContext.save()
        generatedPreview = nil
        env.haptics.celebrate()
    }

    private func install(_ response: AIShortcutResponse) async {
        let draft = ShortcutDraft(from: ExampleShortcut(
            id: UUID().uuidString,
            title: response.title,
            summary: response.summary,
            category: response.category,
            icon: response.icon,
            colorHex: response.colorHex,
            actions: response.actions.map { TemplateAction(identifier: $0.identifier, displayName: $0.displayName, parameters: $0.parameters) }
        ))
        try? await env.installer.install(draft)
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Theme.accent : Color.white.opacity(0.85))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            if message.role != .user { Spacer(minLength: 40) }
        }
    }
}

private struct EmptyState: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 50))
                .foregroundStyle(Theme.accent)
            Text("Describe a shortcut idea")
                .font(.title3.bold())
            Text("Try \"text my partner when I leave the office\" or \"play sleep sounds when I plug in to charge\".")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 60)
    }
}

private struct ThinkingDots: View {
    @State private var dot = 0
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Theme.accent.opacity(dot == i ? 0.9 : 0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(280))
                    await MainActor.run { dot = (dot + 1) % 3 }
                }
            }
        }
    }
}

private struct GeneratedPreviewCard: View {
    let response: AIShortcutResponse
    let onInstall: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: response.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Theme.tint(for: response.colorHex), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading) {
                    Text(response.title).font(.headline)
                    Text(response.category.displayName).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text(response.summary).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Button(action: onInstall) {
                    Label("Add to Shortcuts", systemImage: "square.and.arrow.down")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                Button(action: onSave) {
                    Label("Save", systemImage: "tray.and.arrow.down")
                        .font(.subheadline.weight(.medium))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(.white.opacity(0.7), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glassCard()
    }
}

private struct InputBar: View {
    @Binding var text: String
    let isRecording: Bool
    let onSend: () -> Void
    let onMic: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onMic) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.title3)
                    .foregroundStyle(isRecording ? Color.red : Theme.accent)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.7), in: Circle())
            }
            TextField("Describe a shortcut idea…", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 22))
                .submitLabel(.send)
                .onSubmit(onSend)
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : Theme.accent)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
}
