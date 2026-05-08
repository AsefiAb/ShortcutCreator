# Publishing Shortcut Genius to the App Store — 2026 Guide

A no-fluff, step-by-step path from "I've never shipped an iOS app" to "live on the App Store". Reading time: ~20 minutes. Total real-world time: 2-7 days, mostly waiting on Apple.

> Apple changes this stuff annually. URLs, prices, and screen dimensions referenced here are accurate as of early 2026; double-check at [developer.apple.com](https://developer.apple.com) before each step.

## What you'll need

- **A Mac** running macOS 14.5+ (15+ recommended). Apple does not allow iOS app submission from Windows, Linux, or any cloud Mac that hasn't been signed into your Apple Developer account.
- **Xcode 16+** (free from the Mac App Store).
- **An iPhone** running iOS 17+ for testing.
- **A credit card** for the $99/year Apple Developer Program fee.
- **A unique app name** — check availability via App Store Connect before settling.
- **An Apple ID** (the same one you use for the App Store is fine).

---

## Phase 1 — Apple Developer Program enrollment ($99/year)

This is the gatekeeper. You can't submit an app without it. Plan for this taking 24-48 hours, sometimes longer if Apple flags your account for manual review.

### 1.1 Decide: individual or organization?

| | Individual | Organization |
|--|--|--|
| **Cost** | $99/year | $99/year |
| **Verification** | Apple ID + 2FA | DUNS number + legal entity check |
| **App Store seller name** | Your legal name | Your company name |
| **Time to enroll** | Hours | Days to weeks |
| **Recommended for first app** | ✅ | Only if you have a registered company |

For your first app, **start as an Individual**. You can convert later.

### 1.2 Enroll

1. Go to [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll).
2. Sign in with your Apple ID. Make sure 2FA is enabled — Apple requires it.
3. Accept the Apple Developer Agreement.
4. Complete the enrollment form (legal name, address, phone).
5. Pay the $99 USD fee.
6. Wait for the confirmation email. Apple manually reviews enrollments — expect 1-2 days, occasionally a week.

### 1.3 While you wait

You can keep building and testing on your own iPhone using a free Apple ID. Open Xcode → Settings → Accounts → add your Apple ID. Free accounts can sign apps that run on your devices for 7 days at a time.

---

## Phase 2 — App Store Connect setup

[App Store Connect](https://appstoreconnect.apple.com) is the website where you manage your app, screenshots, pricing, and submission. You can only access it after enrollment is approved.

### 2.1 Create the app record

1. **App Store Connect → My Apps → +**.
2. Fill in:
   - **Platform**: iOS.
   - **Name**: `Shortcut Genius` (or your chosen name — must be globally unique on the App Store).
   - **Primary language**: English (U.S.).
   - **Bundle ID**: `com.shortcutgenius.app` (must exactly match your Xcode build).
   - **SKU**: any internal identifier you'll never reuse, e.g. `SHORTCUT_GENIUS_001`.
   - **User access**: Full Access.
3. Click **Create**.

### 2.2 Reserve the bundle ID + capabilities

Still in Apple Developer:

1. [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers) → **+**.
2. Choose **App IDs → App**.
3. Description: `Shortcut Genius`. Bundle ID: explicit, `com.shortcutgenius.app`.
4. Enable capabilities you'll use:
   - App Groups (for the widget to share data).
   - SiriKit (App Intents).
   - In-App Purchase.
5. Save. Repeat with `com.shortcutgenius.app.widgets` for the widget extension.

### 2.3 Create the in-app purchases

In App Store Connect → your app → **In-App Purchases**:

1. **Premium Yearly** — Auto-Renewable Subscription, group `Shortcut Genius Premium`, product ID `com.shortcutgenius.premium.yearly`, price $19.99 USD/year, 7-day free trial.
2. **Premium Lifetime** — Non-Consumable, product ID `com.shortcutgenius.premium.lifetime`, price $49 USD.
3. **Coffee Tip** — Consumable, product ID `com.shortcutgenius.tip.coffee`, price $4.99 USD.

Each needs a localized name + description. Apple won't approve until they're filled in.

---

## Phase 3 — Code signing

### 3.1 Automatic signing (recommended)

In Xcode → your project → **Signing & Capabilities**:

1. Check **Automatically manage signing**.
2. Select your Team.
3. Xcode generates the development + distribution certificates and provisioning profiles automatically.

### 3.2 If automatic signing fails

You'll need to create them manually:

1. [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates) → **+** → Apple Distribution.
2. Follow the prompt to upload a Certificate Signing Request from Keychain Access on your Mac.
3. Download + double-click the .cer to install it.
4. Create a Distribution Provisioning Profile pointing at your bundle ID + the cert above.
5. Download + double-click the .mobileprovision.

Take a screenshot of your "Signing & Capabilities" once green — that page is your sanity check.

---

## Phase 4 — Asset prep

This is where most first-time submissions stall.

### 4.1 App icon

- 1024×1024 PNG, no transparency, no rounded corners (Apple rounds them).
- Place in `Assets.xcassets/AppIcon.appiconset`.
- iOS 18+ also needs **dark** + **tinted** variants. Xcode has slots for all three.

### 4.2 Screenshots

Required sizes (you can let Xcode auto-generate from one source):

- **6.9" iPhone** (iPhone 16 Pro Max): 1320×2868.
- **6.5" iPhone** (older Pro Max): 1284×2778.
- **iPad 13"** (only if you ship for iPad).

Three to ten screenshots per size. They're the #1 conversion lever — make them tell a story:

1. Hero shot — "Turn your idea into a real iOS Shortcut."
2. The 100+ examples grid.
3. The chat creator with a real prompt.
4. The library with saved shortcuts.
5. The widget on the home screen.

Use Xcode's Simulator → File → New Screen Shot. For text overlays, [Rotato](https://rotato.app) or [Screenshots Designer](https://www.screenshots.pro) are good.

### 4.3 App preview video (optional but recommended)

15-30 seconds, MP4 or MOV, same dimensions as screenshots. Boosts conversion 20-40% — worth doing once you have the static screenshots dialed in.

### 4.4 App Store metadata

See [APP_STORE_METADATA.md](APP_STORE_METADATA.md) — copy-paste ready.

### 4.5 Privacy nutrition label

In App Store Connect → App Privacy:

- **Data collected**: choose **No** for everything if you ship the app as-built (we don't collect anything by default).
- **Tracking**: **No**.

If you later add analytics, update this honestly — Apple cross-references it against your code's actual behavior.

---

## Phase 5 — TestFlight beta

Always TestFlight before App Review. It's free, and it surfaces the bugs Review will reject you for.

### 5.1 Archive + upload

1. In Xcode, set the scheme destination to **Any iOS Device (arm64)**.
2. **Product → Archive**. Wait for the archive.
3. In the **Organizer** that opens, click **Distribute App → TestFlight & App Store**.
4. Walk through the wizard. Xcode uploads to App Store Connect — takes 5-15 minutes.

### 5.2 Add internal testers

Internal testers (your team in App Store Connect) can install builds within minutes, no Apple review.

1. App Store Connect → TestFlight → Internal Testing → **+**.
2. Add yourself by email.
3. Open TestFlight on your iPhone, accept the invite, install.

### 5.3 (Optional) External testers

Up to 10,000 external testers can install via a public link or invite, but the **first build per version** needs Apple TestFlight Review (24-48 hours, lighter than App Review). Useful when you want feedback from non-developers.

### 5.4 Iterate

For every change: bump build number, archive, re-upload. New builds reach internal testers in minutes.

---

## Phase 6 — App Review (the real one)

When TestFlight feels solid, submit for App Review.

### 6.1 Submission checklist

In App Store Connect → your app → version 1.0:

- [ ] Build attached (the one you uploaded).
- [ ] Screenshots filled in for every required size.
- [ ] Promotional text + description + keywords (see metadata doc).
- [ ] Support URL — must be a real, public page.
- [ ] Privacy Policy URL — must be a real, public page (a GitHub Gist or simple Notion page is fine for a v1).
- [ ] Age rating questionnaire — answered.
- [ ] App Review information: a test account if your app needs login (we don't), and notes for the reviewer (see below).
- [ ] In-app purchases attached and reviewed.

### 6.2 Notes for the reviewer (paste into "App Review Information → Notes")

```
Shortcut Genius generates iOS Shortcuts from natural-language ideas.

How to test:
1. Open the app, dismiss onboarding.
2. Browse the Discover tab — 100+ ready-to-install shortcuts.
3. Tap any shortcut → "Add to Shortcuts" → confirm in the share sheet → it opens in the native Shortcuts app for the user to confirm install.
4. Open the Create tab → type "remind me to drink water every hour" → tap send. With no API key configured, the on-device fallback matches the closest built-in shortcut. With an OpenAI/Grok key configured in Settings, the AI generates a custom shortcut.

The user must paste their own AI provider API key in Settings if they want cloud generation. We do not bundle any keys, and we never send data to our servers (we don't have servers).

Premium IAP unlocks unlimited generations. The free tier permits 10 generations per month. The "Free forever is fine!" button on the paywall is always visible — there is no dark pattern.
```

### 6.3 Common rejection reasons (and how we avoid them)

- **Guideline 5.1.1 — Data collection without disclosure** → We don't collect anything; the Privacy nutrition label says so.
- **Guideline 3.1.1 — Linking to external purchases** → Our paywall uses StoreKit only.
- **Guideline 4.0 — Spam / minimum functionality** → 100+ pre-built shortcuts means real value even without the AI features.
- **Guideline 5.2.3 — Trademarks** → Our name doesn't reference "Apple," "iOS," or "Shortcuts" in a confusing way. ("Shortcut Genius" is fine; "iOS Shortcuts Pro" would not be.)
- **Hidden features** → Every flow in the UI is reachable from the tab bar.

### 6.4 Submit

Hit **Add for Review → Submit for Review**. Apple's median turnaround in 2026 is 24-48 hours.

If rejected: read the rejection carefully, address the **specific guideline cited**, reply through Resolution Center if you disagree (sometimes works), and resubmit.

---

## Phase 7 — Launch day

When approval lands:

1. Choose **Manually release this version** if you want to launch on a specific day.
2. Set pricing (Free tier with IAP is correct for our model).
3. Set release territories — start with everywhere, exclude markets where you're not ready to handle local laws.
4. Hit **Release**.

The app appears on the App Store within a few hours.

---

## Ongoing

- **Updates**: every shipped change goes through App Review again. Bug fixes < 24 hours. New features 24-48 hours.
- **Subscription management**: users can cancel from their iCloud account at any time — Apple handles the plumbing.
- **Tax forms**: App Store Connect → Agreements, Tax, and Banking. You **must** complete these before Apple will pay you.
- **Receipts**: keep an eye on Sales and Trends; the data is delayed by ~24 hours.

## Resources

- [Apple Developer documentation](https://developer.apple.com/documentation/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)

When in doubt: post in the [Apple Developer Forums](https://developer.apple.com/forums/) — Apple engineers answer there directly.
