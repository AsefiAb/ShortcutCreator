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
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Environment(AppEnvironment.self) private var env
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Group {
            if hasOnboarded {
                MainTabView()
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
        .tint(Theme.accent)
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable { case home, chat, library, settings }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Discover", systemImage: "sparkles") }
                .tag(Tab.home)

            ChatView()
                .tabItem { Label("Create", systemImage: "wand.and.stars") }
                .tag(Tab.chat)

            LibraryView()
                .tabItem { Label("Library", systemImage: "square.stack.3d.up") }
                .tag(Tab.library)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}
