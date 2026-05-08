import Foundation
import SwiftData

@Model
final class ChatMessage {
    @Attribute(.unique) var id: UUID
    var roleRaw: String
    var content: String
    var createdAt: Date
    var generatedShortcutID: UUID?

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        createdAt: Date = .now,
        generatedShortcutID: UUID? = nil
    ) {
        self.id = id
        self.roleRaw = role.rawValue
        self.content = content
        self.createdAt = createdAt
        self.generatedShortcutID = generatedShortcutID
    }

    var role: Role {
        Role(rawValue: roleRaw) ?? .user
    }

    enum Role: String, Codable {
        case user
        case assistant
        case system
    }
}

@Model
final class UsageRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var kind: String

    init(id: UUID = UUID(), date: Date = .now, kind: String) {
        self.id = id
        self.date = date
        self.kind = kind
    }

    static func generationsThisMonth(in context: ModelContext) -> Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: .now)?.start ?? .distantPast
        let descriptor = FetchDescriptor<UsageRecord>(
            predicate: #Predicate { $0.kind == "ai_generation" && $0.date >= startOfMonth }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
