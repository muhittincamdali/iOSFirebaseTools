# Examples

Both examples use iOSFirebaseTools from this checkout (a local package reference to `../..`).

## FirebaseLab

An iOS app for notes that belong to their author:

- create an account, sign in with e-mail and password, or continue without an account;
- stay signed in across launches (the session is in the keychain);
- write, pin and delete notes in Cloud Firestore (swipe a row or long-press it for its menu),
  with the creation time set by the server;
- see the user, the sign-in provider read from the ID token's claims, and the token itself only
  as `Secret(redacted, … characters)`.

Security Rules in [`Emulators/firestore.rules`](../Emulators/firestore.rules) let each user read
and change only their own notes.

By default the app talks to the Firebase Local Emulator Suite on your Mac, so it needs no
Firebase account. Install the [Firebase CLI](https://firebase.google.com/docs/cli)
(`npm install -g firebase-tools`) and Java 21 or later, then:

1. Start the emulators from the repository root: `scripts/start-emulators.sh`.
2. Open `Examples/FirebaseLab/FirebaseLab.xcodeproj` in Xcode 26 or later.
3. Choose the **FirebaseLab** scheme and an iPhone simulator, and press **Run** (⌘R).

To use a real project instead, add its `GoogleService-Info.plist` to the FirebaseLab target and
enable **Email/Password** and **Anonymous** sign-in and Cloud Firestore with the rules above in
the Firebase console.

The UI tests in `FirebaseLabUITests` run against the emulators: they sign up, add and pin notes,
check that a second user sees none of them and that they come back after signing in again,
relaunch the app and find the session restored from the keychain, show the error for a wrong
password, and sign in anonymously.

```sh
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools \
  "xcodebuild test -project Examples/FirebaseLab/FirebaseLab.xcodeproj -scheme FirebaseLab \
   -destination 'platform=iOS Simulator,name=iPhone 17 Pro'"
```

[`scripts/capture-screenshots.sh`](../scripts/capture-screenshots.sh) runs the sign-up test in
light and dark appearance to make the README screenshots in `docs/images/`.

The README samples live in
[`FirebaseLab/ReadmeSamples.swift`](FirebaseLab/FirebaseLab/ReadmeSamples.swift). The app uses
them, and the package's test target compiles them through the symlink
`Tests/iOSFirebaseToolsTests/ReadmeExamples.swift` and runs them against the emulators.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](FirebaseLab/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.

## ConfigCheck

`fbcheck`, a command-line tool for two jobs that do not belong in an app:

```sh
cd Examples/ConfigCheck

# Check a GoogleService-Info.plist: exits with 1 if it belongs to another app or is damaged.
swift run fbcheck plist ../../MyApp/GoogleService-Info.plist --bundle-id com.example.myapp

# Verify an ID token the way a server does, against Google's published keys.
swift run fbcheck token "$ID_TOKEN" --project my-app-1a2b3

# The same for a token from the Authentication emulator.
swift run fbcheck token "$ID_TOKEN" --project demo-iosfirebasetools --emulator
```

The plist check exits with 1 when it finds a problem, so a CI step can stop a build that would
ship the plist of another app or environment.
