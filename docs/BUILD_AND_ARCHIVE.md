# Build & archive guide — iOS and macOS

Targets:

- **`ShortcutGenius (iOS)`** — iPhone + iPad app, deployment target iOS 18.
- **`ShortcutGenius (macOS)`** — native Mac app, deployment target macOS 15.

Both share the same SwiftUI codebase. Platform-specific surfaces (sidebar, menu-bar extra, scanner) are gated by `#if os(...)` and live under `Features/Mac/` and `Features/Scan/`.

## Prerequisites

- macOS 14.5+ host (15+ recommended).
- Xcode 16+.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`.
- Apple Developer Program membership (for distribution; free Apple ID is fine for local builds on your own devices).

## One-time project generation

```bash
git clone https://github.com/AsefiAb/ShortcutCreator.git
cd ShortcutCreator
brew install xcodegen
xcodegen generate
open ShortcutGenius.xcodeproj
```

Re-run `xcodegen generate` any time you change `project.yml`.

---

## Local builds

### iOS — Simulator

In Xcode: scheme **`ShortcutGenius (iOS)`**, destination iPhone Simulator → ⌘R.

Or from the command line:

```bash
xcodebuild \
  -project ShortcutGenius.xcodeproj \
  -scheme "ShortcutGenius (iOS)" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### iOS — physical device

1. Plug in your iPhone, trust the computer.
2. Xcode → Signing & Capabilities → set Team to your Apple ID.
3. Select your iPhone in the destination dropdown → ⌘R.

A free Apple ID can sign apps that run for 7 days before re-installation. A paid Developer Program account ($99/year) signs them indefinitely.

### macOS

Scheme **`ShortcutGenius (macOS)`**, destination "My Mac" → ⌘R.

Command line:

```bash
xcodebuild \
  -project ShortcutGenius.xcodeproj \
  -scheme "ShortcutGenius (macOS)" \
  -destination "platform=macOS" \
  -configuration Debug \
  build
```

The macOS app launches with a sidebar layout, a Settings window (`⌘,`), and a `wand.and.stars` menu-bar extra for quick generation.

---

## Archives (App Store / Mac App Store)

### iOS archive

```bash
xcodebuild \
  -project ShortcutGenius.xcodeproj \
  -scheme "ShortcutGenius (iOS)" \
  -destination "generic/platform=iOS" \
  -configuration Release \
  -archivePath build/ShortcutGenius-iOS.xcarchive \
  archive
```

Then:

- In Xcode: **Window → Organizer → Archives → Distribute App → TestFlight & App Store**.
- Or via `xcodebuild -exportArchive` with an `ExportOptions.plist` for fully scripted CI.

### macOS archive

```bash
xcodebuild \
  -project ShortcutGenius.xcodeproj \
  -scheme "ShortcutGenius (macOS)" \
  -destination "generic/platform=macOS" \
  -configuration Release \
  -archivePath build/ShortcutGenius-macOS.xcarchive \
  archive
```

Then in Organizer → **Distribute App → Mac App Store** for App Store distribution, or **Developer ID** for direct distribution outside the Mac App Store.

### Notarization (Developer ID only)

If you ship the macOS app outside the Mac App Store, you must notarize it:

```bash
xcrun notarytool submit \
  build/ShortcutGenius.app.zip \
  --apple-id "you@example.com" \
  --team-id "ABCDEFGHIJ" \
  --password "$APP_SPECIFIC_PASSWORD" \
  --wait

xcrun stapler staple build/ShortcutGenius.app
```

`APP_SPECIFIC_PASSWORD` is generated from [appleid.apple.com](https://appleid.apple.com/) → Sign-In and Security → App-Specific Passwords. Don't reuse your real Apple ID password.

---

## Validate before submitting

```bash
xcodebuild -validateArchive \
  -archivePath build/ShortcutGenius-iOS.xcarchive
```

Or in Organizer: **Validate App** before **Distribute App**. Catches missing icon sizes, malformed Info.plist, and missing privacy strings before App Review does.

---

## CI (GitHub Actions)

`.github/workflows/ci.yml` builds both targets on every push to main and on pull requests, using the `macos-15` runner.

It does **not** archive or upload — that requires App Store Connect API keys, which we don't add until you're ready to ship via CI. When you are: see [Apple's `xcodebuild` docs on `-allowProvisioningUpdates`](https://developer.apple.com/documentation/xcode/) plus the `App Store Connect API` GitHub Action.
