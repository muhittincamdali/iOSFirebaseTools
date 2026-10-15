#!/usr/bin/env bash
# Starts the Firebase Authentication and Firestore emulators with the repository's settings
# and Security Rules (Emulators/firebase.json), for FirebaseLab and for `swift test`.
#
# Needs the Firebase CLI (`npm install -g firebase-tools`) and Java 21 or later.
#
# Usage: scripts/start-emulators.sh
# In another terminal, run the package's emulator tests with:
#   FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 swift test
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root/Emulators"
exec firebase emulators:start --only auth,firestore --project demo-iosfirebasetools
