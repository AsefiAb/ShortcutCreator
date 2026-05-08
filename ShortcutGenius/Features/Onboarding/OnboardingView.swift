import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private let pages: [OnboardPage] = [
        .init(icon: "sparkles", title: "Welcome to Shortcut Genius",
              subtitle: "Browse 100+ ready-made shortcuts and install them with one tap."),
        .init(icon: "wand.and.stars", title: "Describe any idea",
              subtitle: "Type or speak it. We turn it into a real iOS Shortcut you can run."),
        .init(icon: "lock.shield.fill", title: "Private by design",
              subtitle: "Everything stays on your device. Bring your own AI key only when you need it.")
    ]

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(spacing: 28) {
                Spacer(minLength: 40)
                cardArea
                    .frame(maxWidth: 540)
                    .frame(height: 380)
                Button(action: advance) {
                    Text(page == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                Button("Skip") { onFinish() }
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var cardArea: some View {
        #if os(iOS)
        TabView(selection: $page) {
            ForEach(Array(pages.enumerated()), id: \.offset) { idx, p in
                OnboardCard(page: p).tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        #else
        // Audit fix: page-style TabView is iOS-only. macOS uses a transition.
        VStack(spacing: 16) {
            OnboardCard(page: pages[page])
                .id(page)
                .transition(.opacity.combined(with: .scale))
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Theme.accent : Color.secondary.opacity(0.3))
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .animation(.spring(duration: 0.35), value: page)
                }
            }
        }
        #endif
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            onFinish()
        }
    }
}

private struct OnboardPage {
    let icon: String
    let title: String
    let subtitle: String
}

private struct OnboardCard: View {
    let page: OnboardPage
    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: page.icon)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .padding(36)
                .background(.white.opacity(0.65), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: Theme.accent.opacity(0.25), radius: 24)
            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
