#!/usr/bin/env bash
# Local development helper. Loads ANTHROPIC_API_KEY (and friends) from .env
# into your current shell so xcodebuild + Xcode runs can pick them up via
# ProcessInfo.processInfo.environment.
#
# Usage:
#   source scripts/setup-secrets.sh
#
# In production (App Store builds), keys live ONLY in the iPhone Keychain,
# entered by the user in Settings. .env is for dev convenience.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "No .env found. Copy .env.example to .env and fill it in:"
  echo "  cp .env.example .env"
  return 1 2>/dev/null || exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ROOT_DIR/.env"
set +a

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "ANTHROPIC_API_KEY: loaded (${#ANTHROPIC_API_KEY} chars)"
else
  echo "ANTHROPIC_API_KEY: not set"
fi
