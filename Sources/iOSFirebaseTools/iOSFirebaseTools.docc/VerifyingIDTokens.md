# Verifying ID Tokens

Check on your own server that a request comes from a signed-in Firebase user.

## Overview

An app sends ``FirebaseAuthClient/idToken(forceRefresh:)`` to your API in an
`Authorization: Bearer` header. Firebase's Admin SDKs verify these tokens in Node.js, Java,
Python, Go and C#, but not in Swift. ``IDTokenVerifier`` follows the rules Firebase documents
for verifying tokens with a third-party library:

- The header's `alg` is `RS256`, and its `kid` names one of Google's current public keys.
- The signature is valid for that key.
- `aud` is your project ID, and `iss` is `https://securetoken.google.com/<project ID>`.
- `sub` is not empty; it is the user's ID.
- `exp` is in the future; `iat` and `auth_time` are in the past.

```swift
import iOSFirebaseTools

let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3") // create once

func userID(from request: Request) async throws -> String {
    guard let header = request.headers["Authorization"], header.hasPrefix("Bearer ") else {
        throw HTTPError.unauthorized
    }
    let claims = try await verifier.verify(String(header.dropFirst(7)))
    return claims.subject
}
```

Any failure throws ``TokenError``; answer it with `401 Unauthorized`.

## Keys and caching

The verifier downloads Google's JSON Web Key Set from ``IDTokenVerifier/googleKeysURL`` when it
first needs it and keeps it as long as the response's `Cache-Control: max-age` allows (at most
a day). Concurrent verifications share one download.

A token whose `kid` is not in the set causes at most one new download a minute, so a stream of
forged tokens cannot make your server flood Google with requests. If Google cannot be reached
when the keys expire, the keys already downloaded keep working until a download succeeds.

## Claims

``IDTokenClaims`` has the standard claims, the user's e-mail and sign-in provider, and every
other claim in ``IDTokenClaims/all``, including custom claims you set with the Admin SDK:

```swift
let claims = try await verifier.verify(token)
if claims["admin"] == true {
    // allow administrative actions
}
print(claims.signInProvider ?? "unknown") // "password", "anonymous", "apple.com", …
```

## Clock skew

Servers and Google's token service rarely agree to the second. The verifier allows 60 seconds
of difference by default; pass `clockSkew:` from 0 to 300. Values outside that range are
clamped, and NaN or infinity count as 0, so a configuration mistake cannot turn off the expiry
check.

## The Authentication emulator

The emulator issues unsigned tokens (`alg: none`). ``IDTokenVerifier/emulator(projectID:clock:)``
accepts exactly those, checks every claim, and rejects signed tokens, so a verifier built for
the emulator cannot accept production tokens by mistake. Never deploy it.

## What the verifier does not check

Firebase's Admin SDKs can also ask Firebase whether a token was revoked (`checkRevoked`), which
needs a service account. If you revoke refresh tokens, for example when a user changes their
password, keep token lifetimes in mind: an ID token stays valid until it expires, at most an
hour after it was issued.

Session cookies (`iss` is `https://session.firebase.google.com/<project ID>`) are a different
token type and are not accepted.
