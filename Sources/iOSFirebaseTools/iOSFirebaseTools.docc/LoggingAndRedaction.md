# Logging and Redaction

What the package's values show when you print or log them, and what they never show.

## Overview

Apps log requests, responses, sessions and errors while they debug a sign-in or a failing
query. Those values carry ID tokens, refresh tokens, passwords, e-mail addresses and document
IDs. Every type in the package that can hold one of them writes a redacted text form for
`print`, string interpolation, `dump`, `debugPrint`, `Mirror` and the debugger.

The rule is default-safe: **what the code does not fully understand is hidden, never shown.**
The text forms are a safety net for values that reach a log by accident. They are not a
guarantee, and they cannot find secrets in text you write yourself. Keep secrets out of logs in
the first place, and prefer structured logging such as `os.Logger` with `privacy: .private`.

## What is shown and what is never shown

| Value                                  | Shown                                                                                                | Never shown                                                                         |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| ``Secret``                               | its length                                                                                           | the value                                                                           |
| ``AuthSession``                          | the first 10 characters of the user ID, anonymous or not, expiry                                     | tokens, e-mail address                                                              |
| ``HTTPRequest``, ``HTTPResponse``          | method, scheme, host, port, path, query names, allowlisted headers, status, body size and media type | body, user info, fragment, query values, ID-like path segments, other header values |
| ``AuthError``, ``FirestoreError``          | the code and HTTP status                                                                             | the server's message                                                                |
| ``TokenError``, ``ValidationError``        | short printable values you passed or the token holds, paths with IDs as `:id`                        | long, multi-line or token-like values                                               |
| ``FirebaseProject``, ``GoogleServiceInfo`` | project ID, database, bundle ID, emulators                                                           | the API key                                                                         |

The full values stay available in code: ``Secret/revealed``, ``AuthSession/email``,
``AuthError/message``, ``FirestoreError/message`` (with the link that creates a missing index),
and the stored properties of every request and response. Those are not redacted; show them to a
developer, not in a log.

## Requests and responses

```swift
let request = HTTPRequest(
    method: "POST",
    url: URL(string: "https://securetoken.googleapis.com/v1/token?key=AIza…")!,
    headers: ["Content-Type": "application/x-www-form-urlencoded", "Authorization": "Bearer eyJ…"],
    body: Data("grant_type=refresh_token&refresh_token=AMf-vB…".utf8)
)
print(request)
// HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
//   headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
//   body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

- **Bodies** are never shown. The text says how many bytes there were and the media type of
  `Content-Type`, or `unknown content type` when that header is not a plain media type.
- **URLs** always lose user info (`user:pass@`) and the fragment. Query names are shown; their
  values only for names on ``RedactionPolicy``'s list, which is empty by default.
- **Path segments** that look like identifiers become `:id`: UUIDs, segments with 6 or more
  digits, mixed letter and digit tokens of 16 characters or more (Firestore's document IDs and
  Firebase user IDs), e-mail addresses, JWTs and long base64 or hex runs. The segment after a
  secret name (`/token/…`) or after a segment that is not plain ASCII becomes `:id` as well.
- **Paths that could be read two ways** keep scheme and host only: dot segments (`..`, `%2E`),
  `;` matrix parameters, double encoding (`%25`) and more than 32 segments. A host that names a
  secret (`myapp://pin/4831`) also keeps nothing after it, and a host that is not a plain DNS
  name or IP address is hidden.
- **Headers** keep their values only for `content-type`, `content-length`, `accept`,
  `user-agent`, `cache-control` and `etag`. A header whose name contains `token`, `secret`, `key`,
  `auth`, `session`, `signature`, `cookie` or `password` stays hidden even when you list it.

## Names that are not plain ASCII are hidden

Before a name is compared with the list of secret names, it is percent-decoded, normalized with
NFKC, case-folded, and `_`, `-`, `.` and spaces are dropped. A name that is still not plain
ASCII letters and digits is treated as secret: `şifre`, a Cyrillic `р` inside `password`, a
zero-width joiner or a combining accent all hide the value. This hides some harmless names on
purpose; the alternative, tables of look-alike letters, never ends.

Values are also checked by detectors, whatever their name: e-mail addresses (Unicode local
parts and domains included), bearer tokens, JWTs, base64 or hex runs of 32 characters or more,
card numbers that pass the Luhn check, and IBANs that pass the mod-97 check.

## Your own allowlist

Pass a ``RedactionPolicy`` to show more in your own logs, for example in a transport that wraps
``URLSessionTransport``:

```swift
struct LoggingTransport: HTTPTransport {
    let base = URLSessionTransport()
    let policy = RedactionPolicy(allowedHeaders: RedactionPolicy.defaultAllowedHeaders.union(["x-request-id"]),
                                 allowedQueryParameters: ["pageSize"])

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        print(request.redactedDescription(policy))
        let response = try await base.send(request)
        print(response.redactedDescription(policy))
        return response
    }
}
```

Listing a secret name, such as `authorization` or `key`, does not make its value visible. Pass
`recordsHostOnly: true` to write every URL as scheme, host and port only.

## What it does not find

- Text you write yourself: `print("password is \(password)")` is not redacted.
- Values inside your own models and the documents you read: a ``FirestoreDocument`` prints its
  data as your model prints it.
- A short secret in a path segment that looks like an ordinary word, such as `/notes/hunter2`.
  Put secrets in headers or bodies, never in URLs.

## Limits

Every redaction step is bounded, so a hostile or broken value cannot make logging slow or crash
the app: URLs over 8 KiB print as `<unparsed URL>`, at most 32 path segments, 32 query items
and 64 headers are listed, header and query values over 256 characters are hidden, and echoed
values over 120 characters are replaced by their length. The tests run a megabyte of input of
each kind on a thread with a 512 KiB stack.
