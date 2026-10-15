# Getting Started

Add the package, point it at your Firebase project, sign a user in and save a document.

## Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/iOSFirebaseTools` and add the `iOSFirebaseTools` library to
your app target. In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "2.0.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "iOSFirebaseTools", package: "iOSFirebaseTools")
    ])
]
```

The package needs iOS 17, macOS 14, tvOS 17, watchOS 10 or visionOS 1, and Swift 6.2 (Xcode 26)
or later. It has no dependencies.

## Prepare the Firebase project

In the [Firebase console](https://console.firebase.google.com):

1. Add an iOS app with your bundle ID and download its `GoogleService-Info.plist`. Add the file
   to your app target.
2. Under **Authentication › Sign-in method**, enable the providers you use: **Email/Password**
   and **Anonymous** are the ones this package signs in with.
3. Create a **Cloud Firestore** database and give it Security Rules. These rules let each user
   read and write only their own notes:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteID} {
      allow get: if request.auth != null && (resource == null || resource.data.ownerID == request.auth.uid);
      allow list, delete: if request.auth != null && resource.data.ownerID == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.ownerID == request.auth.uid;
      allow update: if request.auth != null && resource.data.ownerID == request.auth.uid
        && request.resource.data.ownerID == resource.data.ownerID;
    }
  }
}
```

You can do all of this without a Firebase account against the Local Emulator Suite; see
<doc:TestingWithTheEmulators>.

## Create the clients

Create one ``FirebaseAuthClient`` and one ``FirestoreClient`` for the whole app. The project
comes from the plist; ``GoogleServiceInfo/problems(bundleIdentifier:)`` catches the common
mistake of shipping the plist of another app or build configuration.

```swift
import iOSFirebaseTools

let project = try GoogleServiceInfo.inMainBundle().project()
let auth = FirebaseAuthClient(project: project)            // keeps the session in the keychain
let firestore = FirestoreClient(project: project, credentials: .user(auth))
```

``FirestoreClient/Credentials/user(_:)`` makes every Firestore request carry the user's ID
token, so Security Rules see `request.auth`.

## Sign in

```swift
// The session saved by an earlier launch, or a new anonymous user.
var session = try await auth.restoreSession()
if session == nil {
    session = try await auth.signInAnonymously()
}
print(session!) // AuthSession(user: 6kkpCpjp8Z…, email: none, anonymous: true, …): no tokens
```

E-mail and password sign-in throw ``AuthError`` with a ``AuthError/Code`` you can switch over;
see <doc:SigningIn>.

## Save and read documents

Documents are `Codable` models. A `Date` becomes a Firestore timestamp, and a transform lets the
server set it so the device's clock cannot get it wrong.

```swift
struct Note: Codable, Sendable {
    var text: String
    var ownerID: String
    var createdAt: Date?
}

let path = try await firestore.add(
    Note(text: "Buy milk", ownerID: session.userID),
    to: "notes",
    transforms: ["createdAt": .serverTimestamp]
)

let mine = FirestoreQuery(collection: "notes").filter("ownerID", .equal, session.userID)
for note in try await firestore.documents(matching: mine, as: Note.self) {
    print(note.id, note.data.text, note.data.createdAt ?? "pending")
}
```

<doc:WorkingWithFirestore> covers updates, batches, paging and the limits the client checks.

## Use the token on your server

Send ``FirebaseAuthClient/idToken(forceRefresh:)`` to your own API in an `Authorization` header.
A Swift server checks it with ``IDTokenVerifier``; see <doc:VerifyingIDTokens>.
