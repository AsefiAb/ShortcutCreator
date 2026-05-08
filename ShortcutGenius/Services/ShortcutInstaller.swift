import Foundation
import Observation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// Audit fix: v1 was iOS-only (UIActivityViewController). Now multiplatform:
// iOS share-sheets the .shortcut file (which the Shortcuts app can import),
// macOS shows an NSSavePanel so the user can save the file anywhere.
@Observable
@MainActor
final class ShortcutInstaller {
    enum InstallError: LocalizedError {
        case writeFailed
        case noPresenter
        case unsupported
        case userCancelled

        var errorDescription: String? {
            switch self {
            case .writeFailed: return "Couldn't write the shortcut file."
            case .noPresenter: return "Couldn't find a window to present the share sheet."
            case .unsupported: return "Your device version doesn't support this."
            case .userCancelled: return nil
            }
        }
    }

    private(set) var lastExportedURL: URL?
    private(set) var isExporting = false

    func install(_ draft: ShortcutDraft) async throws {
        isExporting = true
        defer { isExporting = false }

        let data = try ShortcutFileBuilder.buildPlistData(for: draft)
        let url = try writeToTemp(data: data, title: draft.title)
        lastExportedURL = url

        #if os(iOS)
        try await presentShareSheet(for: url)
        #elseif os(macOS)
        try await saveWithPanel(temp: url, suggestedName: sanitize(draft.title))
        #else
        throw InstallError.unsupported
        #endif
    }

    private func writeToTemp(data: Data, title: String) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShortcutGenius", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(sanitize(title) + ".shortcut")
        try data.write(to: url, options: .atomic)
        return url
    }

    private func sanitize(_ title: String) -> String {
        var safe = title
        for invalid in ["/", ":", "\\", "?", "*", "\"", "<", ">", "|"] {
            safe = safe.replacingOccurrences(of: invalid, with: "-")
        }
        return safe.replacingOccurrences(of: " ", with: "_")
    }

    #if os(iOS)
    private func presentShareSheet(for url: URL) async throws {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
            throw InstallError.noPresenter
        }
        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = presenter.view
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            activity.completionWithItemsHandler = { _, _, _, _ in
                continuation.resume()
            }
            presenter.present(activity, animated: true)
        }
    }
    #endif

    #if os(macOS)
    private func saveWithPanel(temp: URL, suggestedName: String) async throws {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "shortcut") ?? .data]
        panel.nameFieldStringValue = suggestedName + ".shortcut"
        panel.title = "Save shortcut"
        panel.message = "The Shortcuts app will pick it up if you save into iCloud Drive's Shortcuts folder."

        let response = await panel.beginSheetModalAsync()
        guard response == .OK, let dest = panel.url else { throw InstallError.userCancelled }

        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        try FileManager.default.copyItem(at: temp, to: dest)
        // Try to open with Shortcuts.app if installed.
        NSWorkspace.shared.open(dest)
    }
    #endif
}

#if os(macOS)
private extension NSSavePanel {
    func beginSheetModalAsync() async -> NSApplication.ModalResponse {
        await withCheckedContinuation { (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
            if let window = NSApplication.shared.keyWindow {
                self.beginSheetModal(for: window) { response in
                    continuation.resume(returning: response)
                }
            } else {
                let response = self.runModal()
                continuation.resume(returning: response)
            }
        }
    }
}
#endif
