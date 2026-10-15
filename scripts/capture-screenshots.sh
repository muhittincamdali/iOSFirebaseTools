#!/usr/bin/env bash
# Captures the README screenshots from the FirebaseLab UI tests on an iPhone simulator, in light
# and dark appearance. The tests sign up, write and pin notes and open the account screen
# against the Firebase Local Emulator Suite, which this script starts with the repository's
# Security Rules (Emulators/firebase.json).
#
# Needs the Firebase CLI (`npm install -g firebase-tools`) and Java 21 or later.
#
# Usage: scripts/capture-screenshots.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="$repo_root/docs/images"
shots=(sign-in notes account)
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$output_dir" "$work/shots"

device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  udid="$device"
else
  udid="$(xcrun simctl list devices available | grep -m1 -F "$device (" | grep -oE '[0-9A-F-]{36}' || true)"
fi
if [[ -z "$udid" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

echo "Building FirebaseLab for $udid"
xcodebuild build-for-testing \
  -project "$repo_root/Examples/FirebaseLab/FirebaseLab.xcodeproj" \
  -scheme FirebaseLab -destination "id=$udid" -derivedDataPath "$work/build" -quiet

# English (US) and a clean status bar, so every run produces the same pictures.
xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >/dev/null
if [[ "$(xcrun simctl spawn "$udid" defaults read -g AppleLocale 2>/dev/null || true)" != "en_US" ]]; then
  echo "Switching the simulator to English (US)"
  xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array en
  xcrun simctl spawn "$udid" defaults write -g AppleLocale -string en_US
  xcrun simctl shutdown "$udid"
  xcrun simctl boot "$udid"
  xcrun simctl bootstatus "$udid" -b >/dev/null
fi
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""

for appearance in light dark; do
  xcrun simctl ui "$udid" appearance "$appearance"
  (cd "$repo_root/Emulators" && firebase emulators:exec --only auth,firestore --project demo-iosfirebasetools \
    "TEST_RUNNER_SCREENSHOT_DIR='$work/shots' TEST_RUNNER_APPEARANCE=$appearance \
     xcodebuild test-without-building -project '$repo_root/Examples/FirebaseLab/FirebaseLab.xcodeproj' \
       -scheme FirebaseLab -destination id=$udid -derivedDataPath '$work/build' \
       -only-testing:FirebaseLabUITests/FirebaseLabUITests/testSignUpWriteAndPinNotes") \
    > "$work/test-$appearance.log" 2>&1 \
    || { grep -E "error:|failed" "$work/test-$appearance.log" >&2; exit 1; }
done

for appearance in light dark; do
  for shot in "${shots[@]}"; do
    file="$output_dir/$shot-$appearance.png"
    cp "$work/shots/$shot-$appearance.png" "$file"
    # Half the width of an iPhone 17 Pro screenshot keeps the README light.
    sips --resampleWidth 603 "$file" >/dev/null
    echo "$file"
  done
done

xcrun simctl status_bar "$udid" clear
