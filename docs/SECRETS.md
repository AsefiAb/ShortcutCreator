# Handling API keys securely

Shortcut Genius is **bring-your-own-key**. We don't ship any AI keys, we don't proxy through a server, and we never see your traffic.

This guide covers:

1. [The one canonical env var name](#the-one-canonical-env-var-name)
2. [How keys flow through the app](#how-keys-flow-through-the-app)
3. [Local development](#local-development)
4. [GitHub Secrets / CI](#github-secrets--ci)
5. [Production builds](#production-builds)
6. [What to do if a key leaks](#what-to-do-if-a-key-leaks)

---

## The one canonical env var name

```
ANTHROPIC_API_KEY
```

That's it. This name matches the [official Anthropic SDK convention](https://docs.anthropic.com/) — anywhere you see code that reads `os.environ.get("ANTHROPIC_API_KEY")` or `ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]`, the same name applies.

In **GitHub Actions**, store it as a repository secret named exactly `ANTHROPIC_API_KEY`. Don't add prefixes (`SHORTCUT_`, `APP_`, etc.) — those just create drift between repos.

The codebase also recognises:

| Provider | Env var |
|----------|---------|
| Anthropic Claude | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| xAI / Grok | `XAI_API_KEY` |

All three follow each provider's official SDK naming. Don't rename them.

---

## How keys flow through the app

```
       ┌────────────────────┐
       │  User pastes key   │
       │  in Settings → AI  │
       └─────────┬──────────┘
                 │
                 ▼
       ┌────────────────────┐
       │   Keychain         │   kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
       │   (per device)     │   — never syncs, never escapes the device
       └─────────┬──────────┘
                 │
                 ▼
       ┌────────────────────┐
       │  APIKeyResolver    │   1. Keychain
       │  resolves at call  │   2. ProcessInfo.environment[ANTHROPIC_API_KEY]
       │  site (priority)   │   3. nil → error: "missing API key"
       └─────────┬──────────┘
                 │
                 ▼
       ┌────────────────────┐
       │ AnthropicProvider  │   POST https://api.anthropic.com/v1/messages
       │ AnthropicProvider  │   x-api-key: <key>
       └────────────────────┘
```

The relevant code lives in [`Services/AnthropicProvider.swift`](../ShortcutGenius/Services/AnthropicProvider.swift) (`APIKeyResolver` type) and [`Services/KeychainStore.swift`](../ShortcutGenius/Services/KeychainStore.swift).

---

## Local development

For local dev where you want to skip the in-app paste flow:

```bash
cp .env.example .env
# edit .env, paste your real keys
source scripts/setup-secrets.sh
```

`.env` is git-ignored. `setup-secrets.sh` exports the variables into your shell so `xcodebuild` and `xcrun simctl spawn` runs see them via `ProcessInfo.processInfo.environment`.

To pass them into a Simulator run from Xcode, add them to the scheme's environment variables:

> Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables → `+`
> Name: `ANTHROPIC_API_KEY` &nbsp; Value: `$(ANTHROPIC_API_KEY)`

The `$(ANTHROPIC_API_KEY)` syntax tells Xcode to read the value from the parent environment (your shell) rather than embed it in the scheme.

---

## GitHub Secrets / CI

In your GitHub repository:

1. **Settings → Secrets and variables → Actions → New repository secret**.
2. Name: `ANTHROPIC_API_KEY` (exact case).
3. Value: your real Claude API key.

Reference it in `.github/workflows/ci.yml`:

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

We do this in the `build-ios` and `build-macos` jobs so any tests that hit the live API can authenticate. Most CI runs don't need to call the API at all — keep network-touching tests off the default path so they don't burn quota on every PR.

If you fork the repo, **regenerate your own key** — never reuse a key from another project.

---

## Production builds

For the App Store / TestFlight builds:

- **Don't bundle any keys**. The shipped binary contains no API keys.
- The user pastes their own key in Settings, which writes to the Keychain.
- App Review explicitly checks that the Privacy nutrition label says "no data collected" — leaking a developer-owned key into the binary breaks this claim.

This is also a smart legal move. If your bundled key gets exfiltrated from a shipped app (and they always do, eventually), you're paying for everyone's usage. BYO-key dodges that completely.

---

## What to do if a key leaks

If a key ever ends up in git history (yours or someone else's):

1. **Rotate immediately**: revoke at [console.anthropic.com](https://console.anthropic.com/) and create a new one.
2. Do not just `git revert` — the old commit is still in history. Either accept the rotation as the fix, or for unpushed history, `git filter-repo` to scrub it.
3. Audit GitHub: Settings → Secrets and verify nothing was overwritten.
4. Check usage: console will show any spikes from the leaked window.

`pre-commit` hooks like [`gitleaks`](https://github.com/gitleaks/gitleaks) catch most accidents before they ship — worth the 30-second install.
