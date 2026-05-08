import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var purchasing = false
    @State private var status: String?

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        valueProps
                        plans
                        if let status {
                            Text(status).font(.caption).foregroundStyle(.secondary)
                        }
                        Button("Free forever is fine!") {
                            dismiss()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)

                        Button("Restore purchases") {
                            Task {
                                await env.store.restorePurchases()
                                await env.entitlements.refresh(from: env.store)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(Theme.accent)
            Text("Support the app & keep it ad-free")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("No tricks. Free forever for the basics. Pay only if you love it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private var valueProps: some View {
        VStack(alignment: .leading, spacing: 10) {
            ValueRow(icon: "infinity", text: "Unlimited AI shortcut generations")
            ValueRow(icon: "mic.fill", text: "Advanced voice input")
            ValueRow(icon: "tray.full.fill", text: "Export & history")
            ValueRow(icon: "bolt.heart.fill", text: "Priority support")
            ValueRow(icon: "lock.shield.fill", text: "Local-first privacy, always")
        }
        .padding()
        .glassCard()
    }

    private var plans: some View {
        VStack(spacing: 10) {
            if let yearly = env.store.yearlyProduct {
                PlanCard(
                    title: "Yearly",
                    subtitle: "Best for casual use",
                    price: yearly.displayPrice,
                    cadence: "/ year",
                    accent: Theme.accent,
                    isLoading: purchasing
                ) {
                    Task { await purchase(yearly) }
                }
            } else {
                placeholderCard("Yearly", price: "$19.99", cadence: "/ year")
            }

            if let lifetime = env.store.lifetimeProduct {
                PlanCard(
                    title: "Lifetime",
                    subtitle: "Best deal — pay once",
                    price: lifetime.displayPrice,
                    cadence: "one-time",
                    accent: .pink,
                    badge: "BEST",
                    isLoading: purchasing
                ) {
                    Task { await purchase(lifetime) }
                }
            } else {
                placeholderCard("Lifetime", price: "$49", cadence: "one-time", badge: "BEST")
            }
        }
    }

    private func placeholderCard(_ title: String, price: String, cadence: String, badge: String? = nil) -> some View {
        PlanCard(title: title, subtitle: "Loading…", price: price, cadence: cadence, accent: Theme.accent, badge: badge, isLoading: true, action: {})
            .opacity(0.6)
    }

    private func purchase(_ product: Product) async {
        guard !purchasing else { return }
        purchasing = true
        defer { purchasing = false }
        do {
            let ok = try await env.store.purchase(product)
            await env.entitlements.refresh(from: env.store)
            if ok {
                status = "Thank you for supporting the app."
                try? await Task.sleep(for: .milliseconds(700))
                dismiss()
            } else {
                status = "Purchase didn't complete."
            }
        } catch {
            status = error.localizedDescription
        }
    }
}

private struct ValueRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(Theme.accent).frame(width: 22)
            Text(text).font(.subheadline)
            Spacer()
        }
    }
}

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let price: String
    let cadence: String
    let accent: Color
    var badge: String? = nil
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title).font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(accent.opacity(0.18), in: Capsule())
                                .foregroundStyle(accent)
                        }
                    }
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price).font(.title3.bold())
                    Text(cadence).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(accent.opacity(0.4), lineWidth: 1.5)
            )
            .opacity(isLoading ? 0.7 : 1)
        }
        .buttonStyle(.plain)
    }
}
