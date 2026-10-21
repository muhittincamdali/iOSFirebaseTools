# ``iOSFirebaseTools``

Firebase Authentication and Cloud Firestore for Swift through their REST APIs, with `Codable`
models, the Local Emulator Suite and server-side ID token verification. No dependencies.

## Overview

iOSFirebaseTools talks to Firebase over the documented REST APIs with `URLSession`, so it fits
where the Firebase SDK does not: App Clips and widgets with tight size and memory budgets,
watchOS, command-line tools, and Swift servers that need to check the ID token a client sends.

```swift
import iOSFirebaseTools

struct Note: Codable, Sendable {
    var text: String
    var ownerID: String
}

let project = try GoogleServiceInfo.inMainBundle().project()
let auth = FirebaseAuthClient(project: project)
let firestore = FirestoreClient(project: project, credentials: .user(auth))

let session = try await auth.signInAnonymously()
try await firestore.add(Note(text: "Buy milk", ownerID: session.userID), to: "notes")
```

What it does for you:

- Keeps the session in the keychain and refreshes the ID token before it expires, with one
  request for any number of concurrent callers.
- Maps `Codable` models to Firestore values (`Date` to timestamps, `Data` to bytes) and checks
  Firestore's limits before a request is sent.
- Verifies ID tokens on a server against Google's published keys, following Firebase's rules.
- Treats everything from outside the process as untrusted: response sizes, token sizes, numbers
  that would overflow or trap, emulator addresses and document IDs are all bounded or encoded.
- Keeps logs clean: tokens, e-mail addresses, request bodies, query values, ID-like path segments
  and the server's free-text messages are left out of the text of every value the package
  defines; see <doc:LoggingAndRedaction>.

What it does not do: real-time listeners and offline persistence need Firestore's gRPC
streaming and local cache, which are part of the Firebase SDK, not of the REST API.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:TestingWithTheEmulators>

### Project configuration

- ``FirebaseProject``
- ``GoogleServiceInfo``
- ``EmulatorHost``

### Authentication

- <doc:SigningIn>
- ``FirebaseAuthClient``
- ``AuthSession``
- ``IdentityProviderCredential``
- ``AppleSignInNonce``
- ``AuthError``
- ``SessionStore``
- ``KeychainSessionStore``
- ``InMemorySessionStore``
- ``KeychainError``

### Cloud Firestore

- <doc:WorkingWithFirestore>
- ``FirestoreClient``
- ``FirestoreQuery``
- ``FirestoreDocument``
- ``FirestorePage``
- ``WriteBatch``
- ``FirestoreTransaction``
- ``FieldTransform``
- ``FirestoreError``

### Firestore values and paths

- ``FirestoreValue``
- ``FirestoreEncoder``
- ``FirestoreDecoder``
- ``FirestoreTimestamp``
- ``GeoPoint``
- ``DocumentPath``
- ``CollectionPath``
- ``FieldPath``

### Verifying ID tokens on a server

- <doc:VerifyingIDTokens>
- ``IDTokenVerifier``
- ``IDTokenClaims``
- ``TokenError``
- ``JSONWebToken``
- ``JSONValue``
- ``RSAPublicKey``

### Networking

- ``HTTPTransport``
- ``URLSessionTransport``
- ``HTTPRequest``
- ``HTTPResponse``
- ``TransportError``
- ``MalformedResponseError``

### Values that stay private

- <doc:LoggingAndRedaction>
- ``Secret``
- ``RedactionPolicy``
- ``ValidationError``
