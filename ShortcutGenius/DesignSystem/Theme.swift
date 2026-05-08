import SwiftUI

enum Theme {
    static let accent = Color(red: 0.49, green: 0.36, blue: 1.0)
    static let bgGradientTop = Color(red: 0.96, green: 0.95, blue: 1.0)
    static let bgGradientBottom = Color(red: 1.0, green: 0.97, blue: 0.94)
    static let cornerLg: CGFloat = 22
    static let cornerMd: CGFloat = 14

    static func tint(for hex: String) -> Color {
        Color(hex: hex) ?? accent
    }
}

extension Color {
    init?(hex: String) {
        var trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        guard trimmed.count == 6, let value = UInt32(trimmed, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
