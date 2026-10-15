# Contributing

Thanks for taking the time to improve iOSFirebaseTools.

## Reporting bugs

Open an issue with:

- the type and method you used, and the arguments,
- what you expected and what happened, including the error,
- whether it happened against Firebase or the Local Emulator Suite, and the CLI version,
- platform, OS version and Xcode version.

Do not put real ID tokens, refresh tokens or private data in an issue. Security problems go
through the [security policy](SECURITY.md), not an issue.

## Setting up

You need Xcode 26 or later. For the end-to-end tests, also the
[Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`) and Java
21 or later; no Firebase account is needed, because the tests use the `demo-iosfirebasetools`
project in the emulators.

## Pull requests

1. Fork the repository and branch from `master`.
2. Keep each pull request focused on one change.
3. Run the tests on macOS with the emulators, and on an iOS simulator:

    ```sh
    firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
    xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

    Without the emulators, `swift test` skips the suite named "Emulator end to end".

4. If you changed the example app, run its UI tests against the emulators:

    ```sh
    firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools \
      "xcodebuild test -project Examples/FirebaseLab/FirebaseLab.xcodeproj -scheme FirebaseLab \
       -destination 'platform=iOS Simulator,name=iPhone 17 Pro'"
    ```

5. Add a test for every change in behaviour in `Tests/iOSFirebaseToolsTests`, with a
   `MockTransport` for requests and responses and, where Firebase's behaviour matters, an
   emulator test. Cover invalid and hostile input, not only the happy path: empty and oversized
   values, `NaN`, infinite and negative numbers, `Int64.min` and `Int64.max`, malformed JSON and
   tokens, IDs with `/`, `?`, `#`, `:` and `%`, and concurrent calls.
6. Public functions validate their input and throw a typed error; they do not crash. Every loop
   and allocation whose size depends on input is bounded. Types that hold a token keep it in a
   `Secret`.
7. If you change a README code sample, change the copy in
   `Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift` as well. That file is what gets
   compiled: by the example app, and by `swift test` through the symlink
   `Tests/iOSFirebaseToolsTests/ReadmeExamples.swift`.
8. If a change affects a screen of the example app shown in the README, regenerate the
   screenshots with `scripts/capture-screenshots.sh`.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode; new code should not add warnings, and
  `xcodebuild docbuild` should stay free of documentation warnings.
- Document public API with DocC comments (`///`), including every parameter, and link the
  Firebase documentation a behaviour comes from.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).
