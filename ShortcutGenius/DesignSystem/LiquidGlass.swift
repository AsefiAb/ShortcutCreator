import SwiftUI

struct LiquidGlassBackground: View {
    var tint: Color = Theme.accent

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.bgGradientTop, Theme.bgGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(tint.opacity(0.18))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: -120, y: -240)
            Circle()
                .fill(Color.pink.opacity(0.18))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: 160, y: 280)
        }
        .ignoresSafeArea()
    }
}

struct GlassCardModifier: ViewModifier {
    var corner: CGFloat = Theme.cornerLg

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(.white.opacity(0.4), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 8)
            }
    }
}

extension View {
    func glassCard(corner: CGFloat = Theme.cornerLg) -> some View {
        modifier(GlassCardModifier(corner: corner))
    }
}
