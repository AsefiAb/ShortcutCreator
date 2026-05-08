#if os(macOS)
import SwiftUI

struct MainSidebarView: View {
    @State private var section: SidebarSection = .discover

    enum SidebarSection: String, CaseIterable, Identifiable, Hashable {
        case discover, create, library, settings
        var id: Self { self }

        var title: String {
            switch self {
            case .discover: return "Discover"
            case .create: return "Create"
            case .library: return "Library"
            case .settings: return "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .discover: return "sparkles"
            case .create: return "wand.and.stars"
            case .library: return "square.stack.3d.up"
            case .settings: return "gearshape"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            detail
                .navigationSplitViewColumnWidth(min: 600, ideal: 880)
        }
        .navigationTitle("Shortcut Genius")
        .frame(minWidth: 880, minHeight: 620)
        .onAppear { wireDeepLink() }
    }

    private var sidebar: some View {
        List(SidebarSection.allCases, selection: $section) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.systemImage)
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var detail: some View {
        switch section {
        case .discover: HomeView()
        case .create: ChatView()
        case .library: LibraryView()
        case .settings: SettingsView()
        }
    }

    private func wireDeepLink() {
        DeepLinkRouter.shared.listeners.append { destination in
            switch destination {
            case .create: section = .create
            case .library: section = .library
            }
        }
    }
}
#endif
