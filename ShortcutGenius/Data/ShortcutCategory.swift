import SwiftUI

enum ShortcutCategory: String, CaseIterable, Codable, Identifiable {
    case driving
    case focus
    case family
    case work
    case health
    case smartHome
    case travel
    case productivity
    case creative
    case wellness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .driving: return "Driving"
        case .focus: return "Focus"
        case .family: return "Family"
        case .work: return "Work"
        case .health: return "Health"
        case .smartHome: return "Smart Home"
        case .travel: return "Travel"
        case .productivity: return "Productivity"
        case .creative: return "Creative"
        case .wellness: return "Wellness"
        }
    }

    var systemImage: String {
        switch self {
        case .driving: return "car.fill"
        case .focus: return "target"
        case .family: return "person.3.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .smartHome: return "house.fill"
        case .travel: return "airplane"
        case .productivity: return "checkmark.circle.fill"
        case .creative: return "paintbrush.fill"
        case .wellness: return "leaf.fill"
        }
    }

    var tint: Color {
        switch self {
        case .driving: return .blue
        case .focus: return .indigo
        case .family: return .pink
        case .work: return .orange
        case .health: return .red
        case .smartHome: return .teal
        case .travel: return .cyan
        case .productivity: return .green
        case .creative: return .purple
        case .wellness: return .mint
        }
    }
}
