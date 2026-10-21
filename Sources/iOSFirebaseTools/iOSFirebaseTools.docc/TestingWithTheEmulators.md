# Testing with the Emulators

Run your app and your tests against the Firebase Local Emulator Suite, and write unit tests
that need no network at all.

## Overview

The Firebase Local Emulator Suite runs Authentication and Firestore on your Mac. Nothing reaches
a real project, Security Rules are enforced, and the data disappears when the emulators stop.

## Start the emulators

Install the Firebase CLI (`npm install -g firebase-tools`) and Java 21 or later, then put this
`firebase.json` next to your rules file:

```json
{
  "firestore": { "rules": "firestore.rules" },
  "emulators": {
    "auth": { "host": "127.0.0.1", "port": 9099 },
    "firestore": { "host": "127.0.0.1", "port": 8080 },
    "ui": { "enabled": false }
  }
}
```

```sh
firebase emulators:start --only auth,firestore --project demo-notes
```

A project ID that starts with `demo-` never touches a real project, so no Firebase account is
needed.

## Point the clients at them

```swift
let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
    .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
let auth = FirebaseAuthClient(project: project)
let firestore = FirestoreClient(project: project, credentials: .user(auth))
```

The iOS simulator shares the Mac's network, so `127.0.0.1` reaches the emulators. The emulators
serve plain HTTP; add `NSAllowsLocalNetworking` to your app's `NSAppTransportSecurity`
dictionary in the Info.plist.

``FirebaseProject/usingEmulatorsFromEnvironment(_:)`` reads `FIREBASE_AUTH_EMULATOR_HOST` and
`FIRESTORE_EMULATOR_HOST`, which `firebase emulators:exec` sets. That makes an integration test
run as simple as:

```sh
firebase emulators:exec --only auth,firestore --project demo-notes 'swift test'
```

Emulator addresses are `host:port` only. A value with a scheme, a path, credentials or a port
outside 1–65535 throws ``ValidationError`` instead of sending requests somewhere unexpected.

## Seed data past the rules

``FirestoreClient/Credentials/emulatorOwner`` sends `Authorization: Bearer owner`, which the
Firestore emulator treats as an administrator:

```swift
let admin = FirestoreClient(project: project, credentials: .emulatorOwner)
try await admin.set(["total": 0], at: "counters/notes")
```

Production rejects that token.

## Unit tests without a network

Every client takes an ``HTTPTransport``. A test transport answers with canned responses and
records what the client sent:

```swift
struct CannedTransport: HTTPTransport {
    let body: String

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        HTTPResponse(statusCode: 200, body: Data(body.utf8))
    }
}

let firestore = FirestoreClient(project: project, transport: CannedTransport(body: """
    {"name":"projects/demo-notes/databases/(default)/documents/notes/n1",
     "fields":{"text":{"stringValue":"hi"},"ownerID":{"stringValue":"u1"}}}
    """))
let note = try await firestore.document("notes/n1", as: Note.self)
```

``FirebaseAuthClient`` also takes a `clock`, so token expiry and refresh can be tested without
waiting an hour, and ``InMemorySessionStore`` keeps tests away from the keychain.
