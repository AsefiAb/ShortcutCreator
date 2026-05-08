import WidgetKit
import SwiftUI
import AppIntents

@main
struct ShortcutGeniusWidgetBundle: WidgetBundle {
    var body: some Widget {
        PopularShortcutsWidget()
        QuickCreateWidget()
    }
}

// MARK: - Popular Shortcuts Widget

struct PopularEntry: TimelineEntry {
    let date: Date
    let shortcuts: [ExampleShortcut]
}

struct PopularProvider: TimelineProvider {
    func placeholder(in context: Context) -> PopularEntry {
        PopularEntry(date: .now, shortcuts: Array(ExampleShortcuts.all.prefix(4)))
    }

    func getSnapshot(in context: Context, completion: @escaping (PopularEntry) -> Void) {
        completion(PopularEntry(date: .now, shortcuts: Array(ExampleShortcuts.all.shuffled().prefix(4))))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PopularEntry>) -> Void) {
        let entry = PopularEntry(date: .now, shortcuts: Array(ExampleShortcuts.all.shuffled().prefix(4)))
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct PopularShortcutsWidgetView: View {
    var entry: PopularProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall: small
        case .systemMedium: medium
        default: medium
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let first = entry.shortcuts.first {
                Image(systemName: first.icon)
                    .foregroundStyle(.white)
                    .font(.title2)
                    .frame(width: 36, height: 36)
                    .background(Theme.tint(for: first.colorHex), in: RoundedRectangle(cornerRadius: 10))
                Text(first.title).font(.headline).lineLimit(1)
                Text(first.summary).font(.caption2).foregroundStyle(.secondary).lineLimit(3)
            }
        }
        .padding(12)
    }

    private var medium: some View {
        let items = Array(entry.shortcuts.prefix(4))
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(items) { item in
                HStack(spacing: 8) {
                    Image(systemName: item.icon)
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .frame(width: 28, height: 28)
                        .background(Theme.tint(for: item.colorHex), in: RoundedRectangle(cornerRadius: 8))
                    Text(item.title).font(.caption.weight(.semibold)).lineLimit(2)
                }
            }
        }
        .padding(10)
    }
}

struct PopularShortcutsWidget: Widget {
    let kind = "PopularShortcutsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PopularProvider()) { entry in
            PopularShortcutsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Popular Shortcuts")
        .description("Shows shortcuts you can install in one tap.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Quick Create Widget

struct QuickCreateEntry: TimelineEntry { let date: Date }

struct QuickCreateProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickCreateEntry { QuickCreateEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (QuickCreateEntry) -> Void) {
        completion(QuickCreateEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickCreateEntry>) -> Void) {
        completion(Timeline(entries: [QuickCreateEntry(date: .now)], policy: .never))
    }
}

struct QuickCreateView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Theme.accent)
            Text("Create Shortcut")
                .font(.subheadline.bold())
            Text("Tap to start")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct QuickCreateWidget: Widget {
    let kind = "QuickCreateWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickCreateProvider()) { _ in
            QuickCreateView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quick Create")
        .description("Tap to open Shortcut Genius and create a new shortcut.")
        .supportedFamilies([.systemSmall])
    }
}
