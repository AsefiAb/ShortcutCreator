import Foundation
import SwiftData

@Model
final class ShortcutAction {
    @Attribute(.unique) var id: UUID
    var order: Int
    var actionIdentifier: String
    var displayName: String
    var parametersJSON: String

    var shortcut: UserShortcut?

    init(
        id: UUID = UUID(),
        order: Int,
        actionIdentifier: String,
        displayName: String,
        parameters: [String: AnyHashable] = [:]
    ) {
        self.id = id
        self.order = order
        self.actionIdentifier = actionIdentifier
        self.displayName = displayName
        self.parametersJSON = ShortcutAction.encode(parameters)
    }

    var parameters: [String: AnyHashable] {
        ShortcutAction.decode(parametersJSON)
    }

    static func encode(_ params: [String: AnyHashable]) -> String {
        let stringy = params.mapValues { "\($0)" }
        guard let data = try? JSONSerialization.data(withJSONObject: stringy),
              let s = String(data: data, encoding: .utf8) else { return "{}" }
        return s
    }

    static func decode(_ json: String) -> [String: AnyHashable] {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return [:] }
        return obj.mapValues { $0 as AnyHashable }
    }
}
