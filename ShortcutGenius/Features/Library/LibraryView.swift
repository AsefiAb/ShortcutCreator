import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserShortcut.createdAt, order: .reverse) private var shortcuts: [UserShortcut]

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                Group {
                    if shortcuts.isEmpty {
                        EmptyLibrary()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(shortcuts) { s in
                                    NavigationLink {
                                        ShortcutDetailView(userShortcut: s)
                                    } label: {
                                        LibraryRow(shortcut: s)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Library")
        }
    }
}

private struct LibraryRow: View {
    let shortcut: UserShortcut

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: shortcut.iconSystemName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Theme.tint(for: shortcut.colorHex), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.title).font(.headline)
                Text(shortcut.summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                Label(shortcut.category.displayName, systemImage: shortcut.category.systemImage)
                    .font(.caption2)
                    .foregroundStyle(shortcut.category.tint)
                    .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .glassCard(corner: 16)
    }
}

private struct EmptyLibrary: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundStyle(Theme.accent)
            Text("Your library is empty")
                .font(.title3.bold())
            Text("Save shortcuts from Discover or generate one with the Create tab.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
