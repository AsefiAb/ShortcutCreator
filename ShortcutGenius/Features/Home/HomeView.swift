import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var search = ""
    @State private var selectedCategory: ShortcutCategory? = nil

    var filtered: [ExampleShortcut] {
        let base: [ExampleShortcut]
        if let selectedCategory {
            base = ExampleShortcuts.filtered(by: selectedCategory)
        } else {
            base = ExampleShortcuts.all
        }
        guard !search.isEmpty else { return base }
        let q = search.lowercased()
        return base.filter {
            $0.title.lowercased().contains(q) || $0.summary.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        SearchField(text: $search)
                            .padding(.horizontal, 16)
                        CategoryStrip(selected: $selectedCategory)
                        shortcutGrid
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                    }
                    .padding(.top, 8)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Discover")
                .font(.largeTitle.bold())
            Text("\(ExampleShortcuts.all.count) ready-to-install shortcuts.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var shortcutGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(filtered) { example in
                NavigationLink {
                    ShortcutDetailView(example: example)
                } label: {
                    ShortcutCard(example: example)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search shortcuts", text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassCard(corner: 16)
    }
}

struct CategoryStrip: View {
    @Binding var selected: ShortcutCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Chip(label: "All", systemImage: "sparkles", isOn: selected == nil, tint: Theme.accent) {
                    selected = nil
                }
                ForEach(ShortcutCategory.allCases) { c in
                    Chip(label: c.displayName, systemImage: c.systemImage, isOn: selected == c, tint: c.tint) {
                        selected = (selected == c) ? nil : c
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct Chip: View {
    let label: String
    let systemImage: String
    let isOn: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(label)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isOn ? tint.opacity(0.18) : .white.opacity(0.6), in: Capsule())
            .overlay(Capsule().stroke(isOn ? tint : .white.opacity(0.6), lineWidth: 1))
            .foregroundStyle(isOn ? tint : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct ShortcutCard: View {
    let example: ExampleShortcut

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: example.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.tint(for: example.colorHex), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
                Image(systemName: example.category.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(example.category.tint)
                    .padding(6)
                    .background(example.category.tint.opacity(0.12), in: Circle())
            }
            Text(example.title)
                .font(.headline)
                .lineLimit(1)
            Text(example.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .glassCard()
    }
}
