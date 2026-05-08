import Foundation
import SwiftData

@Model
final class UserShortcut {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var categoryRaw: String
    var iconSystemName: String
    var colorHex: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var isBuiltIn: Bool
    var promptSource: String?

    @Relationship(deleteRule: .cascade, inverse: \ShortcutAction.shortcut)
    var actions: [ShortcutAction] = []

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        category: ShortcutCategory,
        iconSystemName: String = "bolt.fill",
        colorHex: String = "#7C5CFF",
        createdAt: Date = .now,
        isBuiltIn: Bool = false,
        promptSource: String? = nil,
        actions: [ShortcutAction] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.categoryRaw = category.rawValue
        self.iconSystemName = iconSystemName
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.isFavorite = false
        self.isBuiltIn = isBuiltIn
        self.promptSource = promptSource
        self.actions = actions
    }

    var category: ShortcutCategory {
        ShortcutCategory(rawValue: categoryRaw) ?? .productivity
    }
}
