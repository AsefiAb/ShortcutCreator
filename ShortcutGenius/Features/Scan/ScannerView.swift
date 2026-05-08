import SwiftUI

#if canImport(VisionKit) && os(iOS)
import VisionKit
import UIKit
#endif

struct ScannerView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var detected: String?
    @State private var startedSession = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                content
            }
            .navigationTitle("Scan")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            ZStack(alignment: .bottom) {
                DataScannerRepresentable(detected: $detected)
                    .ignoresSafeArea(edges: .top)
                detectedCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        } else {
            unsupportedView
        }
        #else
        unsupportedView
        #endif
    }

    private var detectedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: detected == nil ? "viewfinder" : "checkmark.circle.fill")
                    .foregroundStyle(detected == nil ? .secondary : .green)
                Text(detected == nil ? "Point at text or a QR code" : "Detected")
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            if let detected {
                Text(detected)
                    .font(.callout)
                    .lineLimit(4)
                Button {
                    DeepLinkRouter.shared.deepLink(.create(prompt: detected))
                } label: {
                    Label("Generate shortcut from this", systemImage: "wand.and.stars")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glassCard()
    }

    private var unsupportedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "viewfinder.circle")
                .font(.system(size: 56))
                .foregroundStyle(Theme.accent)
            Text("Scanning isn't available on this device")
                .font(.title3.bold())
            Text("Use the Create tab to type or speak your idea instead.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#if canImport(VisionKit) && os(iOS)
private struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var detected: String?

    func makeCoordinator() -> Coordinator { Coordinator(detected: $detected) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode(symbologies: [.qr, .ean13, .code128])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var detected: String?
        init(detected: Binding<String?>) { self._detected = detected }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text): detected = text.transcript
            case .barcode(let bar): detected = bar.payloadStringValue ?? "Unrecognised barcode"
            @unknown default: break
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard detected == nil, let first = addedItems.first else { return }
            switch first {
            case .text(let text): detected = text.transcript
            case .barcode(let bar): detected = bar.payloadStringValue
            @unknown default: break
            }
        }
    }
}
#endif
