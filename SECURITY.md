# Security policy

## Supported versions

Security fixes are made for the latest release. Version 1.0.0 is a different, unmaintained code
base (wrappers around the Firebase SDK) and does not receive fixes.

## What counts as a vulnerability

iOSFirebaseTools holds users' tokens and reads data the app does not control: responses from
Firebase or anything posing as it, ID tokens sent to a server, `GoogleService-Info.plist` files,
emulator addresses from the environment. Please report privately anything that makes it:

- accept an ID token it should reject in `IDTokenVerifier`: a bad signature, another
  project's token, an expired token, an unsigned token outside the emulator verifier, a key it
  should not trust;
- reveal a token or refresh token: in a `description`, `dump`, a log line, an error message, a
  file other than the session store, or a request to a host other than Firebase or the
  configured emulator;
- let a password, an e-mail address, a request body, a query value or an ID-like path segment
  through the text form of a value the package defines, against the rules in the
  [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  article (text you log yourself, and short secrets that look like words in a URL path, are
  outside them);
- send a request somewhere unexpected, for example through a document ID, a field path, an
  emulator address or a provider ID that escapes its place in the URL or form body;
- keep a session the user signed out of, or bring it back;
- crash (a trap, an out-of-range index, an integer overflow) instead of throwing;
- run for a very long time or allocate memory out of proportion to its input.

API keys from `GoogleService-Info.plist` are not secrets; Firebase protects data with Security
Rules and API key restrictions. Weak Security Rules in your project are not a vulnerability in
this package.

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include the iOSFirebaseTools version (tag or commit), the platform and OS version, the input that
triggers the problem and what happens. Do not include real tokens; an emulator token or one
from a test project shows the problem just as well.

## What happens next

- You get a reply within 7 days confirming that the report arrived.
- The issue is confirmed, fixed with a regression test, and released together with a GitHub
  security advisory on a disclosure date agreed with you.
- You are credited in the advisory unless you prefer not to be.
