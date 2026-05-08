import Foundation

// Builds a .shortcut plist payload mirroring the layout the iOS Shortcuts
// app expects for unsigned imports. iOS 14+ requires "Allow Untrusted
// Shortcuts" to be enabled in Settings → Shortcuts to install these,
// OR the user must open them through iCloud's signed-shortcuts service.
// For first-class App Store distribution we also expose the same actions
// via App Intents (see AppIntents/ShortcutGeniusAppShortcuts.swift) so
// they appear in the Shortcuts app automatically — no untrusted toggle.
enum ShortcutFileBuilder {

    static func buildPlistData(for shortcut: ShortcutDraft) throws -> Data {
        let workflowActions = shortcut.actions.map { action -> [String: Any] in
            return [
                "WFWorkflowActionIdentifier": action.identifier,
                "WFWorkflowActionParameters": action.parameters
            ]
        }

        let dict: [String: Any] = [
            "WFWorkflowName": shortcut.title,
            "WFWorkflowClientVersion": "2607.0.4",
            "WFWorkflowMinimumClientVersion": 900,
            "WFWorkflowIcon": [
                "WFWorkflowIconStartColor": iconColor(hex: shortcut.colorHex),
                "WFWorkflowIconGlyphNumber": 59511
            ],
            "WFWorkflowImportQuestions": [],
            "WFWorkflowTypes": ["WatchKit", "NCWidget"],
            "WFWorkflowInputContentItemClasses": [
                "WFAppStoreAppContentItem", "WFArticleContentItem",
                "WFContactContentItem", "WFDateContentItem",
                "WFEmailAddressContentItem", "WFGenericFileContentItem",
                "WFImageContentItem", "WFiTunesProductContentItem",
                "WFLocationContentItem", "WFDCMapsLinkContentItem",
                "WFAVAssetContentItem", "WFPDFContentItem",
                "WFPhoneNumberContentItem", "WFRichTextContentItem",
                "WFSafariWebPageContentItem", "WFStringContentItem",
                "WFURLContentItem"
            ],
            "WFWorkflowActions": workflowActions
        ]

        return try PropertyListSerialization.data(
            fromPropertyList: dict,
            format: .binary,
            options: 0
        )
    }

    private static func iconColor(hex: String) -> Int {
        guard let value = UInt32(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else {
            return 0x4280F4FF
        }
        return Int(value << 8 | 0xFF)
    }
}

struct ShortcutDraft {
    var title: String
    var summary: String
    var colorHex: String
    var icon: String
    var actions: [DraftAction]

    init(from example: ExampleShortcut) {
        self.title = example.title
        self.summary = example.summary
        self.colorHex = example.colorHex
        self.icon = example.icon
        self.actions = example.actions.map {
            DraftAction(identifier: $0.identifier, parameters: $0.parameters)
        }
    }

    init(from user: UserShortcut) {
        self.title = user.title
        self.summary = user.summary
        self.colorHex = user.colorHex
        self.icon = user.iconSystemName
        self.actions = user.actions.sorted { $0.order < $1.order }.map {
            DraftAction(identifier: $0.actionIdentifier,
                        parameters: $0.parameters.mapValues { "\($0)" })
        }
    }
}

struct DraftAction {
    let identifier: String
    let parameters: [String: String]
}
