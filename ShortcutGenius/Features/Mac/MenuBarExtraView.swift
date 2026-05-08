#if os(macOS)
import SwiftUI
import SwiftData
import AppKit

struct MenuBarExtraView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @State private var idea = ""
    @State private var status: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wand.and.stars").foregroundStyle(Theme.accent)
                Text("Shortcut Genius").font(.headline)
                Spacer()
                Button {
                    openMain()
                } label: {
                    Image(systemName: "arrow.up.right.square")
                }
                .buttonStyle(.plain)
                .help("Open the main window")
            }

            Divider()

            Text("Quick generate")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("Describe a shortcut idea", text: $idea, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack {
                Button("Generate") {
                    Task { await generate() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(idea.trimmingCharacters(in: .whitespaces).isEmpty || env.aiService.isGenerating)

                if env.aiService.isGenerating {
                    ProgressView().controlSize(.small)
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }

            if let status {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(14)
        .frame(width: 320)
    }

    private func openMain() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.canBecomeMain {
            window.makeKeyAndOrderFront(nil)
            return
        }
    }

    private func generate() async {
        let prompt = idea.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        guard env.entitlements.canGenerate else {
            status = "You're at your monthly free limit. Open the app to upgrade."
            return
        }
        do {
            let response = try await env.aiService.generate(prompt: prompt)
            saveAndOffer(response)
            env.entitlements.recordGeneration()
            status = "Created \"\(response.title)\". Saved to Library."
            idea = ""
        } catch {
            status = error.localizedDescription
        }
    }

    private func saveAndOffer(_ response: AIShortcutResponse) {
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
            promptSource: idea,
            actions: actions
        )
        modelContext.insert(shortcut)
        try? modelContext.save()
        modelContext.insert(UsageRecord(kind: "ai_generation"))
        try? modelContext.save()
    }
}
#endif
