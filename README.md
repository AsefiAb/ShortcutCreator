# Shortcut Genius

A multiplatform indie app for **iOS 18+** and **macOS 15+** that turns plain-English ideas into real iOS Shortcuts. 100+ ready-made templates, AI-powered generation (Claude, OpenAI, or Grok — your choice, your key), and one-tap install into the native Shortcuts app.

> **Status**: production-grade scaffold, audited, multiplatform. Compile + ship from a Mac.

## Highlights

- **Native iOS + macOS** from one codebase. iPhone gets a tab bar + DataScanner. Mac gets a sidebar, a Settings scene, a `⌘N` keyboard shortcut, and a menu-bar extra for quick generation without opening the app.
- **100+ shortcuts** seeded across 10 categories (Driving, Focus, Family, Work, Health, Smart Home, Travel, Productivity, Creative, Wellness).
- **AI provider abstraction**: Anthropic Claude (default), OpenAI, xAI/Grok, or fully on-device pattern matching. Keys stay in the iPhone Keychain.
- **App Intents + AppShortcutsProvider** — your custom shortcuts appear in the Shortcuts app, in Spotlight, and in Siri automatically. No "Allow Untrusted Shortcuts" toggle needed.
- **WidgetKit**: Popular Shortcuts + Quick Create on the iOS home screen.
- **Privacy manifest**, no third-party SDKs, no analytics, no telemetry.
- **StoreKit 2** with yearly subscription, lifetime purchase, optional tip — and a "Free forever is fine!" exit on every paywall.

## Repo layout

```
ShortcutCreator/
├── ShortcutGenius/                    Shared SwiftUI source
│   ├── App/                           App entry, environment, Scenes
│   ├── Models/                        SwiftData models, entitlements, prefs
│   ├── Data/                          100+ examples + .shortcut builder
│   ├── Features/                      UI features
│   │   ├── Home/                      Discover screen
│   │   ├── Chat/                      AI creator
│   │   ├── Library/                   Saved shortcuts
│   │   ├── Detail/                    Shortcut detail
│   │   ├── Settings/                  Settings + paywall
│   │   ├── Onboarding/                Onboarding
│   │   ├── Scan/                      iOS DataScanner integration
│   │   └── Mac/                       macOS sidebar + menu-bar extra
│   ├── Services/                      AI providers, StoreKit, Keychain, Speech, Haptics, Installer
│   ├── AppIntents/                    AppShortcutsProvider
│   ├── DesignSystem/                  Theme + Liquid Glass
│   ├── Resources/                     Info.plist (iOS), macOS-Info.plist, entitlements, privacy manifest
│   └── Assets.xcassets/               AppIcon + AccentColor
├── ShortcutGeniusWidgets/             WidgetKit extension
├── ShortcutGeniusTests/               Unit tests
├── StoreKitConfig/                    .storekit for IAP testing
├── docs/                              Publishing, build, secrets, privacy, App Store metadata
├── scripts/                           setup-secrets.sh
├── .github/workflows/ci.yml           Builds iOS + macOS on every PR
├── project.yml                        XcodeGen project definition (iOS + macOS targets)
└── setup.sh                           One-command project generation on macOS
```

## Quick start

```bash
# On a Mac
git clone https://github.com/AsefiAb/ShortcutCreator.git
cd ShortcutCreator
brew install xcodegen
./setup.sh
open ShortcutGenius.xcodeproj
```

In Xcode pick **`ShortcutGenius (iOS)`** or **`ShortcutGenius (macOS)`** and run.

For local AI dev:

```bash
cp .env.example .env       # paste your ANTHROPIC_API_KEY
source scripts/setup-secrets.sh
```

Or skip the env-var route entirely and paste your key in **Settings → AI generation** at runtime — that flow works for end users too. The shipping app contains zero bundled keys.

## Documentation

- [`docs/BUILD_AND_ARCHIVE.md`](docs/BUILD_AND_ARCHIVE.md) — local builds + App Store archives for both platforms.
- [`docs/PUBLISHING_GUIDE.md`](docs/PUBLISHING_GUIDE.md) — Apple Developer enrollment → App Store submission, 2026 edition.
- [`docs/SECRETS.md`](docs/SECRETS.md) — `ANTHROPIC_API_KEY` handling, GitHub Secrets, Keychain.
- [`docs/APP_STORE_METADATA.md`](docs/APP_STORE_METADATA.md) — paste-ready App Store Connect copy.
- [`docs/PRIVACY.md`](docs/PRIVACY.md) — public privacy policy.

## Monetization

- **Free forever**: 100+ examples + 10 AI generations/month + on-device fallback.
- **$19.99/year** (7-day trial) → unlimited.
- **$49 lifetime** one-time.
- **$4.99 tip** ("Buy the dev a coffee") — strictly optional.

## License

MIT — see [LICENSE](LICENSE).
