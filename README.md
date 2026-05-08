# Shortcut Genius

An iOS app that turns plain-English ideas into real iOS Shortcuts. 100+ ready-made examples, a chat-based AI generator, and one-tap install into the native Shortcuts app.

> **Status**: Production-ready scaffold. All major features wired up. You'll need a Mac + Xcode to compile, run on a device, and ship.

## What's in here

```
ShortcutCreator/
├── ShortcutGenius/                    iOS app source (Swift + SwiftUI)
│   ├── App/                           App entry, environment
│   ├── Models/                        SwiftData models + entitlements
│   ├── Data/                          100+ seed shortcuts + .shortcut builder
│   ├── Features/                      Home, Chat, Library, Detail, Settings, Paywall, Onboarding
│   ├── Services/                      AI, StoreKit, Keychain, Speech, Haptics
│   ├── AppIntents/                    AppShortcutsProvider for Siri + Shortcuts app
│   ├── DesignSystem/                  Theme + Liquid Glass styling
│   └── Resources/                     Info.plist, PrivacyInfo, entitlements
├── ShortcutGeniusWidgets/             WidgetKit extension (home-screen widgets)
├── ShortcutGeniusTests/               Unit tests
├── StoreKitConfig/                    StoreKit configuration for testing IAP
├── docs/                              Publishing guide + App Store metadata
├── project.yml                        XcodeGen project definition
└── setup.sh                           Generates Xcode project on macOS
```

## Build it (on a Mac)

You need:

- A Mac running macOS 14.5+ (macOS 15+ recommended for iOS 26 SDK).
- [Xcode](https://developer.apple.com/xcode/) 16 or newer.
- An iPhone running iOS 18+ for device testing.
- An [Apple Developer](https://developer.apple.com/programs/) account ($99/year) **only when you're ready to ship to the App Store**. For local testing on your own iPhone, a free Apple ID works.

### Steps

```bash
# 1. Clone
git clone https://github.com/AsefiAb/ShortcutCreator.git
cd ShortcutCreator

# 2. Install XcodeGen (one-time)
brew install xcodegen

# 3. Generate the Xcode project
./setup.sh

# 4. Open in Xcode
open ShortcutGenius.xcodeproj
```

In Xcode:

1. Select the `ShortcutGenius` scheme + your iPhone or a simulator.
2. Under **Signing & Capabilities**, set your Team (free Apple ID is fine for personal builds).
3. Press **Run** (⌘R).

If you don't want XcodeGen, you can also create a fresh "App" project in Xcode (iOS, SwiftUI, Swift, iOS 18 deployment target) and drag the `ShortcutGenius/`, `ShortcutGeniusWidgets/`, and `ShortcutGeniusTests/` folders into it. Configure two targets: app and widget extension.

## Architecture at a glance

- **SwiftData** for all local storage — no cloud sync by default.
- **`@Observable` + `Environment`** for app-wide state (instead of `ObservableObject` + `EnvironmentObject`).
- **App Intents + `AppShortcutsProvider`** — exposes the shortcuts you create as native iOS Shortcuts. This is the App Store-friendly path: shortcuts appear automatically in the Shortcuts app, no "Allow Untrusted Shortcuts" toggle.
- **`.shortcut` plist builder** — for power users who want a stand-alone shortcut file, the app also builds a binary plist that the user can import via the share sheet (requires "Allow Untrusted Shortcuts" in Settings → Shortcuts).
- **AI provider abstraction** — `AIProvider` protocol with `OpenAIProvider`, `GrokProvider`, and `OnDeviceProvider` (heuristic match against the 100+ built-ins). Users paste their own API key in Settings; keys live in the Keychain.
- **StoreKit 2** — subscriptions + non-consumables, transaction listener, restore.
- **WidgetKit** — Popular Shortcuts + Quick Create home-screen widgets.

## Privacy posture

- No analytics. No telemetry. No third-party SDKs.
- All data stays on the device unless the user pastes their own AI key, in which case prompts go to that provider only.
- `PrivacyInfo.xcprivacy` declares only the API access categories actually used (UserDefaults, file timestamps, system boot time, disk space).

## Monetization

- **Free forever**: 100+ examples + 10 AI generations / month + on-device fallback.
- **$19.99/year** with a 7-day free trial → unlimited.
- **$49 lifetime** one-time purchase.
- **$4.99 tip** "Buy the dev a coffee" — strictly optional, never gated.
- Paywall is dismissible on every screen with a "Free forever is fine!" exit.

## Publishing

See [docs/PUBLISHING_GUIDE.md](docs/PUBLISHING_GUIDE.md) for the full step-by-step from "no Apple account" to "live on the App Store", including:

- Apple Developer Program enrollment ($99/year)
- App Store Connect setup
- Screenshots + metadata
- TestFlight beta
- App Review (2026 requirements)

Metadata copy you can paste straight into App Store Connect: [docs/APP_STORE_METADATA.md](docs/APP_STORE_METADATA.md).

## License

MIT — see [LICENSE](LICENSE).
