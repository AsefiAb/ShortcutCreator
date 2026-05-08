import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showingPaywall = false
    @State private var openAIKey = KeychainStore.read(forKey: AIProviderKind.openai.keychainKey) ?? ""
    @State private var grokKey = KeychainStore.read(forKey: AIProviderKind.grok.keychainKey) ?? ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PremiumBanner(isPremium: env.entitlements.isPremium || env.entitlements.lifetimeUnlocked) {
                        showingPaywall = true
                    }
                } header: { Text("Plan") }

                Section {
                    Picker("AI provider", selection: providerBinding()) {
                        ForEach(AIProviderKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }

                    if env.preferences.preferredProvider == .openai {
                        SecureField("OpenAI API key (sk-…)", text: $openAIKey)
                            .textInputAutocapitalization(.never)
                            .onSubmit { KeychainStore.save(openAIKey, forKey: AIProviderKind.openai.keychainKey) }
                        Button("Save key") {
                            KeychainStore.save(openAIKey, forKey: AIProviderKind.openai.keychainKey)
                            env.haptics.tap()
                        }
                    }

                    if env.preferences.preferredProvider == .grok {
                        SecureField("Grok / xAI API key", text: $grokKey)
                            .textInputAutocapitalization(.never)
                        Button("Save key") {
                            KeychainStore.save(grokKey, forKey: AIProviderKind.grok.keychainKey)
                            env.haptics.tap()
                        }
                    }
                } header: { Text("AI generation") } footer: {
                    Text("Keys are stored only in your device's Keychain. We never see them.")
                }

                Section {
                    Toggle("Haptics", isOn: hapticsBinding())
                    Toggle("Liquid Glass effects", isOn: liquidGlassBinding())
                } header: { Text("Feel") }

                Section {
                    Link(destination: URL(string: "https://github.com/AsefiAb/ShortcutCreator")!) {
                        Label("Source code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Link(destination: URL(string: "https://github.com/AsefiAb/ShortcutCreator/issues")!) {
                        Label("Report an issue", systemImage: "ladybug")
                    }
                    NavigationLink {
                        SupportView()
                    } label: {
                        Label("Support the dev", systemImage: "heart")
                    }
                } header: { Text("About") }

                Section {
                    Text("Generations used this month: \(env.entitlements.monthlyGenerationsUsed) / \(EntitlementManager.monthlyFreeQuota)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Free tier resets on the 1st of each month. Premium = unlimited.")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) { PaywallView() }
        }
    }

    private func providerBinding() -> Binding<AIProviderKind> {
        Binding(
            get: { env.preferences.preferredProvider },
            set: { env.preferences.preferredProvider = $0 }
        )
    }

    private func hapticsBinding() -> Binding<Bool> {
        Binding(
            get: { env.preferences.hapticsEnabled },
            set: { env.preferences.hapticsEnabled = $0 }
        )
    }

    private func liquidGlassBinding() -> Binding<Bool> {
        Binding(
            get: { env.preferences.showsLiquidGlass },
            set: { env.preferences.showsLiquidGlass = $0 }
        )
    }
}

private struct PremiumBanner: View {
    let isPremium: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isPremium ? "checkmark.seal.fill" : "sparkles")
                    .foregroundStyle(isPremium ? .green : .yellow)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(isPremium ? "Premium unlocked — thank you!" : "Upgrade to Premium")
                        .font(.headline)
                    Text(isPremium ? "Unlimited generations, all features." : "Unlimited AI gens, voice input, and more.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !isPremium {
                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SupportView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var status: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Buy the dev a coffee")
                    .font(.title2.bold())
                    .padding(.top, 16)
                Text("Free forever is fine — really. If you find this useful, here are a few ways to say thanks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if let tip = env.store.tipProduct {
                    Button {
                        Task { await purchase(tip) }
                    } label: {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Tip — \(tip.displayPrice)")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "heart.fill").foregroundStyle(.pink)
                        }
                        .padding()
                        .glassCard()
                    }
                    .buttonStyle(.plain)
                }

                if let status {
                    Text(status).font(.caption).foregroundStyle(.secondary)
                }

                Text("Free forever is fine!")
                    .font(.subheadline)
                    .padding(.top, 16)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Support")
    }

    private func purchase(_ product: Product) async {
        do {
            let ok = try await env.store.purchase(product)
            status = ok ? "Thank you!" : "Purchase didn't complete."
        } catch {
            status = error.localizedDescription
        }
    }
}
