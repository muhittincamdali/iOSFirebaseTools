# Signing In

Sign users in with e-mail and password or anonymously, keep them signed in across launches, and
send an ID token that is always fresh.

## Overview

``FirebaseAuthClient`` calls Firebase Authentication's REST API (the Identity Toolkit and Secure
Token endpoints). It is an actor: calls run one at a time, and its state is the current
``AuthSession``.

## Sign up, sign in, sign out

```swift
let auth = FirebaseAuthClient(project: project)

try await auth.signUp(email: "ada@example.com", password: "correct horse battery")
try await auth.signIn(email: "ada@example.com", password: "correct horse battery")
try await auth.signInAnonymously()
try await auth.sendPasswordReset(to: "ada@example.com", locale: "en")
try await auth.signOut()
try await auth.deleteAccount() // needs a recent sign-in
```

E-mail addresses and passwords are checked before a request is sent: an address longer than
254 bytes, without `@` or with whitespace or control characters, an empty password or one
longer than 4,096 bytes throws ``ValidationError``.

## Sign in with Apple and other providers

``FirebaseAuthClient/signIn(with:)`` exchanges another provider's token for a Firebase session.
For Sign in with Apple, hash a nonce into the Apple ID request and hand Firebase the raw value,
so Firebase can check that Apple's token was issued for this request:

```swift
import AuthenticationServices

let nonce = AppleSignInNonce()
let request = ASAuthorizationAppleIDProvider().createRequest()
request.requestedScopes = [.fullName, .email]
request.nonce = nonce.sha256

// In the ASAuthorizationController delegate:
let appleCredential = authorization.credential as! ASAuthorizationAppleIDCredential
let identityToken = String(decoding: appleCredential.identityToken!, as: UTF8.self)
try await auth.signIn(with: .apple(idToken: identityToken, rawNonce: nonce.raw))
```

``IdentityProviderCredential/google(idToken:accessToken:)`` does the same with a Google
Sign-In token, and ``IdentityProviderCredential/init(providerID:idToken:accessToken:)`` with
any OpenID Connect provider enabled in the project. Enable each provider under
**Authentication › Sign-in method** first.

## Handle errors

Firebase answers with an error code, which ``AuthError/code`` turns into a value:

```swift
do {
    try await auth.signIn(email: email, password: password)
} catch let error as AuthError {
    switch error.code {
    case .invalidLoginCredentials, .invalidPassword, .emailNotFound:
        show("Wrong e-mail or password.")
    case .tooManyAttempts:
        show("Too many attempts. Try again later.")
    case .userDisabled:
        show("This account has been disabled.")
    default:
        show(error.message)
    }
}
```

Projects created since September 2023 have e-mail enumeration protection on, and answer
``AuthError/Code/invalidLoginCredentials`` for both an unknown e-mail and a wrong password.

## Keep the user signed in

The session is saved in a ``SessionStore`` after every change. The default,
``KeychainSessionStore``, keeps it in the keychain with
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`: background tasks can refresh the token, and
the refresh token never leaves the device in a backup. Call
``FirebaseAuthClient/restoreSession()`` when the app starts:

```swift
if let session = try await auth.restoreSession() {
    print("Welcome back,", session.email ?? "guest")
}
```

To share the session with an app extension or an App Clip, give both targets the same keychain
access group and pass it to the store:

```swift
let store = KeychainSessionStore(accessGroup: "ABCDE12345.com.example.shared")
let auth = FirebaseAuthClient(project: project, store: store)
```

``InMemorySessionStore`` forgets the session when the process ends, for tests and command-line
tools.

## Observe sign-in state

``FirebaseAuthClient/sessionUpdates()`` yields the current session at once and again after
every sign-in, refresh and sign-out:

```swift
for await session in await auth.sessionUpdates() {
    isSignedIn = session != nil
}
```

## Fresh tokens

ID tokens are valid for an hour. ``FirebaseAuthClient/idToken(forceRefresh:)`` returns the
current one, or refreshes it first when it expires within five minutes. Concurrent callers wait
for the same refresh instead of each sending one.

When Firebase rejects the refresh token, because the user was disabled or deleted, or changed
their password elsewhere, the client clears the session and throws an error whose
``AuthError/requiresSignIn`` is `true`. A network failure keeps the session, so the next call
can try again.

## Tokens never print

``AuthSession/idToken`` and ``AuthSession/refreshToken`` are ``Secret`` values. `print`, string
interpolation, `dump`, `debugPrint` and the debugger show only their length:

```swift
print(session.idToken) // Secret(redacted, 873 characters)
```

Read ``Secret/revealed`` only where the token leaves the process on purpose, such as an
`Authorization` header.

## API keys restricted to iOS apps

If you restricted the Web API key to iOS apps in the Google Cloud console, Google checks the
`X-Ios-Bundle-Identifier` header. ``FirebaseProject`` sends the main bundle's identifier by
default, and ``GoogleServiceInfo/project(databaseID:)`` sends the plist's `BUNDLE_ID`.
