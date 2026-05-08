import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class ShortcutInstaller {
    enum InstallError: LocalizedError {
        case writeFailed
        case noPresenter
        case unsupported

        var errorDescription: String? {
            switch self {
            case .writeFailed: return "Couldn't write the shortcut file."
            case .noPresenter: return "Couldn't find a window to present the share sheet."
            case .unsupported: return "Your device version doesn't support this."
            }
        }
    }

    var lastExportedURL: URL?

    func install(_ draft: ShortcutDraft) async throws {
        let data = try ShortcutFileBuilder.buildPlistData(for: draft)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShortcutGenius", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let filename = sanitize(draft.title) + ".shortcut"
        let url = directory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        lastExportedURL = url

        try presentShareSheet(for: url)
    }

    private func sanitize(_ title: String) -> String {
        title.replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: " ", with: "_")
    }

    private func presentShareSheet(for url: URL) throws {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            throw InstallError.noPresenter
        }
        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let activity = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        activity.popoverPresentationController?.sourceView = presenter.view
        presenter.present(activity, animated: true)
    }
}
