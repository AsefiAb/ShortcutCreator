#!/usr/bin/env bash
# Run on macOS to generate the .xcodeproj from project.yml
set -euo pipefail

if ! command -v xcodegen &>/dev/null; then
  echo "XcodeGen is required. Install with: brew install xcodegen"
  exit 1
fi

xcodegen generate
echo "Project generated. Open ShortcutGenius.xcodeproj in Xcode."
