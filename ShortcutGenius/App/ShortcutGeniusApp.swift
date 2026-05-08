import SwiftUI
import SwiftData

@main
struct ShortcutGeniusApp: App {
    @State private var environment = AppEnvironment()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserShortcut.self,
            ShortcutAction.self,
            ChatMessage.self,
            UsageRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .task {
                    await environment.bootstrap(container: sharedModelContainer)
                }
                .preferredColorScheme(nil)
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Shortcut from Idea…") {
                    DeepLinkRouter.shared.deepLink(.create(prompt: ""))
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            CommandGroup(replacing: .help) {
                Link("Shortcut Genius Help", destination: URL(string: "https://github.com/AsefiAb/ShortcutCreator")!)
            }
        }

        Settings {
            SettingsView()
                .environment(environment)
                .modelContainer(sharedModelContainer)
                .frame(width: 540, height: 620)
        }

        MenuBarExtra("Shortcut Genius", systemImage: "wand.and.stars") {
            MenuBarExtraView()
                .environment(environment)
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}

struct RootView: View {
    @Environment(AppEnvironment.self) private var env
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Group {
            if hasOnboarded {
                #if os(macOS)
                MainSidebarView()
                #else
                MainTabView()
                #endif
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
        .tint(Theme.accent)
    }
}

#if os(iOS)
struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable { case home, chat, scan, library, settings }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Discover", systemImage: "sparkles") }
                .tag(Tab.home)

            ChatView()
                .tabItem { Label("Create", systemImage: "wand.and.stars") }
                .tag(Tab.chat)

            ScannerView()
                .tabItem { Label("Scan", systemImage: "viewfinder") }
                .tag(Tab.scan)

            LibraryView()
                .tabItem { Label("Library", systemImage: "square.stack.3d.up") }
                .tag(Tab.library)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .onAppear { wireDeepLink(selection: $selectedTab) }
    }

    private func wireDeepLink(selection: Binding<Tab>) {
        DeepLinkRouter.shared.listeners.append { destination in
            switch destination {
            case .create: selection.wrappedValue = .chat
            case .library: selection.wrappedValue = .library
            }
        }
    }
}
#endif
