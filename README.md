<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

iOSFirebaseTools is a Swift package for Firebase Authentication and Cloud Firestore that talks to
Firebase's REST APIs with `URLSession` instead of embedding the Firebase SDK. It is for code where
the SDK does not fit or does not exist: App Clips and widgets with tight size and memory budgets,
watchOS, command-line tools, and Swift servers that need to check the ID token an app sends. It
signs users in and keeps their token fresh, maps `Codable` models to Firestore documents, runs
against the Firebase Local Emulator Suite, and verifies ID tokens on a server. It has no
dependencies outside Apple's SDK.

## Highlights

- **Sign-in that stays signed in** — e-mail and password, anonymous, Sign in with Apple and
  Google; the session is kept in the keychain and the ID token is refreshed before it expires,
  with one request for any number of concurrent callers.
- **Firestore with your own types** — read, query, write, batch and run transactions on
  `Codable` models; `Date` becomes a timestamp, and server timestamps and increments are one
  argument.
- **Errors instead of crashes** — an integer that overflows `Int64`, a NaN in an `Int` field, a
  date in the year 10000 or a 20 MB response throws a typed error; paths, field names and limits
  are checked against Firebase's rules before a request is sent.
- **ID tokens checked on your server** — `IDTokenVerifier` applies Firebase's rules for RS256
  tokens with Google's published keys, which the Admin SDKs do for other languages but not Swift.
- **Logs without secrets** — tokens, e-mail addresses, request bodies, query values, ID-like
  path segments and the server's messages are left out of what `print`, `dump`, logs and the
  debugger show; see [What logs show](#what-logs-show).
- **Tested end to end** — 137 Swift Testing tests, 10 of them against the Authentication and
  Firestore emulators with Security Rules, and five UI tests of the example app on a simulator.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Import the module**

```swift
import iOSFirebaseTools
```

**3. Use it**

Add your project's `GoogleService-Info.plist` to the app target, enable **Anonymous** sign-in
and create a Cloud Firestore database in the [Firebase console](https://console.firebase.google.com),
with [Security Rules](Emulators/firestore.rules) that let users write their own notes. Then
replace the `ContentView.swift` of a new iOS app with:

```swift
import iOSFirebaseTools
import SwiftUI

struct ContentView: View {
    @State private var status = "Nothing saved yet"

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
            Button("Save a note to Firestore") {
                Task { status = await saveFirstNote() }
            }
        }
        .padding()
    }
}

func saveFirstNote() async -> String {
    do {
        // Reads the GoogleService-Info.plist in your app target.
        let project = try GoogleServiceInfo.inMainBundle().project()
        let auth = FirebaseAuthClient(project: project)
        let firestore = FirestoreClient(project: project, credentials: .user(auth))

        let session = try await auth.signInAnonymously()
        let note = ["text": "Hello, Firestore", "ownerID": session.userID]
        let path = try await firestore.add(note, to: "notes")
        return "Saved \(path)"
    } catch {
        return "Could not save: \(error)"
    }
}
```

Run the app and tap the button: the text shows `Saved notes/…` and the note appears under
**Firestore Database** in the console. No Firebase project yet? The same code runs against the
emulators on your Mac; see [Testing with the emulators](#testing-with-the-emulators).

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "iOSFirebaseTools", package: "iOSFirebaseTools")
    ])
]
```

## Usage

The samples below are copied from
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift),
which the example app and the package's tests compile; the emulator tests run them.

### Configure the clients once

```swift
func makeClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // The GoogleService-Info.plist you downloaded from the Firebase console.
    let project = try GoogleServiceInfo.inMainBundle().project()
    let auth = FirebaseAuthClient(project: project) // keeps the session in the keychain
    let firestore = FirestoreClient(project: project, credentials: .user(auth))
    return (auth, firestore)
}

func checkConfiguration() throws {
    let info = try GoogleServiceInfo.inMainBundle()
    for problem in info.problems(bundleIdentifier: Bundle.main.bundleIdentifier) {
        // For example: BUNDLE_ID is com.example.notes but the app is com.example.notes.dev
        assertionFailure(problem.description)
    }
}
```

### Sign in

```swift
func signIn(with auth: FirebaseAuthClient, email: String, password: String) async throws -> AuthSession {
    do {
        return try await auth.signIn(email: email, password: password)
    } catch let error as AuthError where error.code == .invalidLoginCredentials {
        print("Wrong e-mail or password")
        throw error
    } catch let error as AuthError where error.code == .tooManyAttempts {
        print("Too many attempts; try again later")
        throw error
    }
}

func currentUserID(with auth: FirebaseAuthClient) async throws -> String {
    // The session saved by an earlier launch, or a new anonymous user.
    if let session = try await auth.restoreSession() { return session.userID }
    return try await auth.signInAnonymously().userID
}
```

`auth.idToken()` returns a token that is valid for at least five more minutes, refreshing it if
needed. Sign in with Apple is `auth.signIn(with: .apple(idToken:rawNonce:))`, with
`AppleSignInNonce` for the nonce; the
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
guide has the full flow.

### Read and write documents

```swift
struct Note: Codable, Sendable, Equatable {
    var text: String
    var ownerID: String
    var pinned = false
    var createdAt: Date? // set by the server
}

func addNote(_ text: String, ownerID: String, to firestore: FirestoreClient) async throws -> String {
    let note = Note(text: text, ownerID: ownerID)
    return try await firestore.add(note, to: "notes", transforms: ["createdAt": .serverTimestamp])
}

func loadNotes(ownerID: String, from firestore: FirestoreClient) async throws -> [FirestoreDocument<Note>] {
    let query = FirestoreQuery(collection: "notes")
        .filter("ownerID", .equal, ownerID)
        .limit(100)
    return try await firestore.documents(matching: query, as: Note.self)
}

func pinNote(at path: String, in firestore: FirestoreClient) async throws {
    try await firestore.update(path, fields: ["pinned": true])
}
```

### Write atomically

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Read and write in a transaction

```swift
/// Flips `pinned` even when two devices tap at once: the read and the write happen together.
func togglePin(at path: String, in firestore: FirestoreClient) async throws -> Bool? {
    try await firestore.runTransaction { transaction in
        guard let note = try await transaction.document(path, as: Note.self) else { return nil }
        try transaction.update(path, fields: ["pinned": .bool(!note.data.pinned)])
        return !note.data.pinned
    }
}
```

If another write changes the note between the read and the commit, Firestore aborts the commit
and the closure runs again, up to five times by default.

### Check the token on your server

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Testing with the emulators

Start the Authentication and Firestore emulators with the [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes`; Java 21 or later), and
point the clients at them. A project ID that starts with `demo-` needs no Firebase account.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

An iOS app also needs `NSAllowsLocalNetworking` under `NSAppTransportSecurity` in its Info.plist,
because the emulators serve plain HTTP. For unit tests without any network, every client takes
an `HTTPTransport` you can replace.

## Demo

| Sign in                                                 | Notes in Firestore                                | Account and token                                       |
| ------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------- |
| ![Sign-in screen, light](docs/images/sign-in-light.png) | ![Notes list, light](docs/images/notes-light.png) | ![Account screen, light](docs/images/account-light.png) |
| ![Sign-in screen, dark](docs/images/sign-in-dark.png)   | ![Notes list, dark](docs/images/notes-dark.png)   | ![Account screen, dark](docs/images/account-dark.png)   |

The screenshots come from the UI tests of the example app on an iPhone simulator, run against the
Firebase Local Emulator Suite by [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh):
the test signs up, writes three notes, pins one (pinned notes come first) and opens the account
screen, where the ID token appears only as `Secret(redacted, … characters)`.

To try it yourself, run `scripts/start-emulators.sh`, open `FirebaseLab.xcodeproj` in
[`Examples/FirebaseLab`](Examples/FirebaseLab), choose an iPhone simulator and press **Run**.
[Examples/README.md](Examples/README.md) has the details, and the `fbcheck` command-line tool in
[`Examples/ConfigCheck`](Examples/ConfigCheck) checks plists and verifies tokens.

## What logs show

Every value in the package that can hold a token, a password or personal data prints a
redacted form. What the code does not fully understand is hidden:

| Value                                  | Shown                                                        | Never shown                                                       |
| -------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------- |
| `Secret`                               | its length                                                   | the value                                                         |
| `AuthSession`                          | start of the user ID, anonymous or not, expiry               | tokens, e-mail address                                            |
| `HTTPRequest`, `HTTPResponse`          | method, host, path, query names, allowlisted headers, status | bodies, user info, fragments, query values, ID-like path segments |
| `AuthError`, `FirestoreError`          | code and HTTP status                                         | the server's message (read `message` in code)                     |
| `FirebaseProject`, `GoogleServiceInfo` | project ID, database, bundle ID                              | the API key                                                       |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

Names are compared after percent-decoding, NFKC and case folding, and a name that is still not
plain ASCII, such as `şifre` or a `password` with a Cyrillic letter, is treated as secret.
Bodies are never parsed or shown. `RedactionPolicy` lists the headers and query parameters
whose values your own logs may show.

This is a safety net, not a guarantee: it cannot redact text you write yourself, and a short
secret in a URL path can look like an ordinary word. Keep secrets out of logs and URLs in the
first place. The [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
article has the full rules and limits.

## Documentation

Reference documentation and articles:

- [API reference](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, published to GitHub Pages from `master`)
- Build it locally in Xcode with **Product › Build Documentation**, or from the command line:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — add the package, prepare the Firebase project, sign in and save a document
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — e-mail, anonymous, Apple and Google sign-in, errors, the keychain session and fresh tokens
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — models, queries, writes, transforms, batches, transactions and the limits the client checks
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — Firebase's rules, key caching, claims and clock skew on a Swift server
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — the Local Emulator Suite, `emulators:exec` and unit tests with a test transport
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  — what requests, sessions and errors show in logs, the allowlist, and what is not found
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)).

## Requirements

| Platform  | Minimum version       |
| --------- | --------------------- |
| iOS       | 17                    |
| macOS     | 14                    |
| tvOS      | 17                    |
| watchOS   | 10                    |
| visionOS  | 1                     |
| Toolchain | Swift 6.2 · Xcode 26+ |

The package uses the Security framework and CryptoKit, so it does not build on Linux. CI builds
with the default Xcode of GitHub's `macos-26` runner image; the package is developed with
Xcode 27. The emulator tests need the Firebase CLI and Java 21 or later.

## Architecture

- `Project/`: `FirebaseProject` (project ID, API key, database, emulators) and
  `GoogleServiceInfo`, which reads and checks the plist.
- `Auth/`: `FirebaseAuthClient`, an actor over the Identity Toolkit and Secure Token REST APIs;
  `AuthSession` and the `SessionStore` it is saved in (keychain or memory); provider credentials.
- `Firestore/`: `FirestoreClient`, a `Sendable` struct over the Firestore REST API;
  `FirestoreValue` with its JSON form, the `Codable` encoder and decoder, paths, queries and
  `WriteBatch` and `FirestoreTransaction`. All writes go through the `commit` endpoint, so a
  single write, a batch and a transaction behave the same.
- `Tokens/`: `JSONWebToken` parsing, `IDTokenClaims` and `IDTokenVerifier` with RSA keys from
  Google's JSON Web Key Set.
- `Transport/`: the `HTTPTransport` protocol and its `URLSession` implementation, the only place
  that touches the network.
- `Support/`: `Secret`, `ValidationError` and the redaction rules shared by every text form.
- Input from outside the process is bounded: response bodies (16 MiB), tokens (16 KiB), plists
  (64 KiB), nesting depth, number ranges before any conversion, and emulator addresses
  (`host:port` only).

Run the tests locally:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Roadmap

- Add the package to the Swift Package Index; `.spi.yml` is already in the repository.
- Linking providers to an existing user, and e-mail verification.
- A Linux build of `IDTokenVerifier` on swift-crypto.

Real-time listeners and the offline cache are not planned: they need Firestore's gRPC streaming
connection, which the REST API does not offer.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
