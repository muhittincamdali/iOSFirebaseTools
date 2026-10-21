# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-21

A rebuild. 1.x wrapped the Firebase iOS SDK; 2.0 talks to Firebase Authentication and Cloud
Firestore through their REST APIs, has no dependencies, and adds server-side ID token
verification. The 1.x API (`FirebaseToolsManager`, the per-service managers, `FirebaseMigrator`)
is gone; see "Removed".

### Added

- `FirebaseProject` with checked project IDs, API keys, database IDs and bundle IDs, and the Local
  Emulator Suite by address or from `FIREBASE_AUTH_EMULATOR_HOST` and `FIRESTORE_EMULATOR_HOST`.
  `EmulatorHost` accepts `host:port` only.
- `GoogleServiceInfo`: reads `GoogleService-Info.plist` and reports a plist from another app, a
  damaged API key or app ID, and a sender ID from another project.
- `FirebaseAuthClient`, an actor over the Identity Toolkit and Secure Token APIs: sign-up and
  sign-in with e-mail and password, anonymous sign-in, Sign in with Apple, Google and other
  providers (`IdentityProviderCredential`, `AppleSignInNonce`), password reset, account deletion
  and sign-out. ID tokens refresh five minutes before they expire, with one request for
  concurrent callers; a rejected refresh token ends the session, a network failure does not.
- `AuthSession` kept in a `SessionStore`: `KeychainSessionStore` (after first unlock, this device
  only, optional access group) or `InMemorySessionStore`; `sessionUpdates()` streams changes.
- `AuthError` with the Identity Toolkit's codes, including `INVALID_LOGIN_CREDENTIALS`.
- `FirestoreClient`: read, list by page, structured queries (`FirestoreQuery` with filters,
  ordering, limits and collection groups), add, set with merge, update by field path, delete,
  `WriteBatch` for up to 500 atomic writes, and `FieldTransform` (server timestamp, increment,
  array union and remove). Reads retry twice on transient errors; a `401` retries once with a
  refreshed token.
- `FirestoreValue` with the REST API's JSON form, `FirestoreEncoder` and `FirestoreDecoder` for
  `Codable` models, `FirestoreTimestamp`, `GeoPoint`, and `DocumentPath`, `CollectionPath` and
  `FieldPath` with Firestore's naming rules.
- `IDTokenVerifier` for servers: RS256 signatures against Google's JSON Web Key Set (cached for
  `max-age`, refetched at most once a minute for unknown key IDs), audience, issuer, subject and
  time checks with a bounded clock skew, and an emulator mode that accepts unsigned tokens only.
- `FirestoreClient.runTransaction(maxAttempts:_:)` and `FirestoreTransaction`: read-write
  transactions whose reads see one state of the database and whose writes commit only if
  nothing they read changed; an aborted commit, or a read that fails with `ABORTED` or a
  transient error, runs the closure again in a new transaction, up to 5 attempts by
  default. FirebaseLab pins notes with one.
- `Secret`, which hides tokens from `print`, `dump`, `debugPrint` and `Mirror`, and redacted
  text forms for every value that can carry a credential or personal data: `AuthSession` and
  `IDTokenClaims` (no tokens, no e-mail address, no custom claim values), `AppleSignInNonce`
  (its length only), `HTTPRequest` and `HTTPResponse` (no bodies, user info, fragments,
  query values or ID-like path segments; header values for an allowlist only), `AuthError` and
  `FirestoreError` (code and status, not the server's message), `TokenError` and
  `ValidationError` (only short printable values), and `FirebaseProject` and
  `GoogleServiceInfo` (no API key). `RedactionPolicy` and `redactedDescription(_:)` let an app
  allow more headers and query parameters in its own logs, or record URLs as scheme, host and
  port only.
- `HTTPTransport` with `URLSessionTransport`, which stops reading a response past 16 MiB and
  throws `TransportError.network` with the `URLError` code when a connection fails.
- tvOS 17, watchOS 10 and visionOS 1 support next to iOS 17 and macOS 14.
- `Emulators/` with the emulator configuration and Security Rules, and end-to-end tests that run
  against them.
- Example app `Examples/FirebaseLab` with five UI tests against the emulators (README screenshots
  from `scripts/capture-screenshots.sh`), and
  `Examples/ConfigCheck` (`fbcheck`) for plists and token verification.
- A DocC catalog with six articles, including Logging and Redaction, published to GitHub Pages.

### Changed

- Swift 6.2 tools and the Swift 6 language mode; iOS 17 and macOS 14 minimum.

### Removed

- The Firebase SDK dependency and the wrappers around it: analytics, messaging, storage, security
  and performance managers, `FirebaseToolsManager` and `FirebaseMigrator`. Analytics,
  Crashlytics, Cloud Messaging and Storage are not part of 2.0.
- CocoaPods support; the package installs with Swift Package Manager.
- The generated `Documentation/` folder, templates and benchmark page.

### Security

- Every value from outside the process is bounded or checked: response and token sizes, plist
  size, JSON nesting, `integerValue` strings outside `Int64`, `expiresIn` values that are not
  1–86400 decimal seconds, dates that are NaN or outside the years 0001–9999, `Cache-Control`
  values that would overflow, and NaN or infinite clock skews.
- Document IDs are percent-encoded per URL segment, and provider IDs are checked, so neither can
  change where a request goes or which fields a form carries. A `+` in a page token or
  transaction ID is sent as `%2B`, so Google's servers do not read it as a space.
- Text forms follow one default-safe rule: names are compared after percent-decoding, NFKC and
  case folding, and a name that is still not plain ASCII is treated as secret; detectors hide
  e-mail addresses, bearer tokens, JWTs, long base64 or hex runs, Luhn card numbers and mod-97
  IBANs; and every step is bounded (8 KiB URLs, 32 path segments and query items, 64 headers,
  256-character values), so a hostile value cannot slow down or crash logging. Header names
  pass the same checks as query names, and compound names such as `resetToken` or
  `userpassword` hide the path segment after them. A failed connection never carries the
  request URL, so the API key in `?key=` cannot reach a log through a `URLError`. Error messages no longer quote values from
  `JSONDecoder`, `EncodingError` or the token, and `dump`, `debugPrint` and the debugger show
  errors through the same text forms, not their stored server messages or token values.

## [1.0.0] - 2026-02-02

Initial release: wrappers around the Firebase iOS SDK for Authentication, Analytics, Firestore,
Storage, Cloud Messaging and App Check.

[Unreleased]: https://github.com/muhittincamdali/iOSFirebaseTools/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/iOSFirebaseTools/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/iOSFirebaseTools/releases/tag/v1.0.0
