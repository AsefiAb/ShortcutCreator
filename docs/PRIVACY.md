# Privacy Policy — Shortcut Genius

_Last updated: 2026-05-07._

Shortcut Genius is built privacy-first. This page describes — in plain English — what the app does and does not do with your data.

## Short version

- We don't have servers.
- We don't collect, store, or transmit any of your data.
- The only network calls the app makes are to whichever AI provider you've explicitly configured (OpenAI or xAI/Grok), using the API key you typed in yourself. Those providers have their own privacy policies, which apply to those calls.
- All shortcuts, chats, and preferences live on your iPhone's local SwiftData store.
- API keys live in the iPhone Keychain. We have no way to read them.

## What the app stores locally on your device

- Shortcuts you save to your library, including title, description, and the actions inside them.
- Chat history with the in-app generator.
- Your preferences (haptics, theme, AI provider choice).
- A monthly counter of AI generations used (for the free-tier limit).
- Your OpenAI/Grok API key, if you've added one — stored in the iPhone Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.

## What the app sends over the network

- **Nothing**, unless you've configured a cloud AI provider in Settings.
- If you've configured a provider: when you tap "Generate," the app sends the text of your message to that provider's API. The provider receives the prompt and your API key. It returns the generated Shortcut JSON. The app does not log, retain, or forward this anywhere else.

## Third-party SDKs

None. The app uses only Apple frameworks (SwiftUI, SwiftData, StoreKit, AppIntents, WidgetKit, Speech, Security/Keychain).

## Tracking

None. No analytics, no crash reporting, no advertising IDs.

## Your rights

Because we don't collect anything, there's nothing to access, delete, or port. If you uninstall the app, all data is gone.

## Children

The app is rated 4+. We do not knowingly collect data from anyone, including children.

## Contact

Open an issue at https://github.com/AsefiAb/ShortcutCreator/issues, or email the address listed on that repository.
