import SwiftUI
import SwiftData

struct ShortcutDetailView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let example: ExampleShortcut?
    let userShortcut: UserShortcut?

    @State private var showingError: String?

    init(example: ExampleShortcut) {
        self.example = example
        self.userShortcut = nil
    }

    init(userShortcut: UserShortcut) {
        self.example = nil
        self.userShortcut = userShortcut
    }

    private var title: String { example?.title ?? userShortcut?.title ?? "" }
    private var summary: String { example?.summary ?? userShortcut?.summary ?? "" }
    private var icon: String { example?.icon ?? userShortcut?.iconSystemName ?? "bolt.fill" }
    private var colorHex: String { example?.colorHex ?? userShortcut?.colorHex ?? "#7C5CFF" }
    private var category: ShortcutCategory { example?.category ?? userShortcut?.category ?? .productivity }

    private var actionRows: [(String, String)] {
        if let example {
            return example.actions.map { ($0.displayName, $0.identifier) }
        }
        if let userShortcut {
            return userShortcut.actions
                .sorted { $0.order < $1.order }
                .map { ($0.displayName, $0.actionIdentifier) }
        }
        return []
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(tint: Theme.tint(for: colorHex))
            ScrollView {
                VStack(spacing: 18) {
                    headerCard
                    actionList
                    actionButtons
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if userShortcut != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            if let userShortcut {
                                modelContext.delete(userShortcut)
                                try? modelContext.save()
                                dismiss()
                            }
                        } label: { Label("Delete", systemImage: "trash") }
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
        }
        .alert("Couldn't install", isPresented: .constant(showingError != nil), actions: {
            Button("OK") { showingError = nil }
        }, message: { Text(showingError ?? "") })
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Theme.tint(for: colorHex), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.title2.bold())
                    Label(category.displayName, systemImage: category.systemImage)
                        .font(.caption)
                        .foregroundStyle(category.tint)
                }
                Spacer()
            }
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassCard()
    }

    private var actionList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What it does")
                .font(.headline)
                .padding(.horizontal, 4)
            ForEach(Array(actionRows.enumerated()), id: \.offset) { idx, row in
                HStack(spacing: 12) {
                    Text("\(idx + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Theme.tint(for: colorHex), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.0).font(.subheadline.weight(.medium))
                        Text(row.1).font(.caption2.monospaced()).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .glassCard(corner: 14)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                Task { await install() }
            } label: {
                Label("Add to Shortcuts", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent, in: Capsule())
                    .foregroundStyle(.white)
            }

            if example != nil {
                Button {
                    saveCopyToLibrary()
                } label: {
                    Label("Save to My Library", systemImage: "tray.and.arrow.down")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .glassCard(corner: 28)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func install() async {
        do {
            let draft: ShortcutDraft
            if let example { draft = ShortcutDraft(from: example) }
            else if let userShortcut { draft = ShortcutDraft(from: userShortcut) }
            else { return }
            try await env.installer.install(draft)
            env.haptics.celebrate()
        } catch {
            showingError = error.localizedDescription
        }
    }

    private func saveCopyToLibrary() {
        guard let example else { return }
        let actions = example.actions.enumerated().map { idx, a in
            ShortcutAction(
                order: idx,
                actionIdentifier: a.identifier,
                displayName: a.displayName,
                parameters: a.parameters.mapValues { $0 as AnyHashable }
            )
        }
        let user = UserShortcut(
            title: example.title,
            summary: example.summary,
            category: example.category,
            iconSystemName: example.icon,
            colorHex: example.colorHex,
            isBuiltIn: true,
            actions: actions
        )
        modelContext.insert(user)
        try? modelContext.save()
        env.haptics.tap()
    }
}
