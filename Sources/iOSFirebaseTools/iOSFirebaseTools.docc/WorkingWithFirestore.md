# Working with Firestore

Read, query and write documents with `Codable` models, atomically when you need to, and know
which of Firestore's limits the client checks for you.

## Overview

``FirestoreClient`` uses Cloud Firestore's REST API. Documents are addressed by slash-separated
paths (`"notes/x7Gk2"`, `"users/ada/notes/n1"`) and decoded into your own types. The client has
no state of its own, so it is a `Sendable` struct you can pass anywhere.

## Models

Any `Codable` type is a document. ``FirestoreEncoder`` and ``FirestoreDecoder`` use Firestore's
own types where they exist:

| Swift                                     | Firestore                   |
| ----------------------------------------- | --------------------------- |
| `String`, `Bool`                          | string, Boolean             |
| `Int`, `Int64` and the other integers     | 64-bit integer              |
| `Double`, `Float`                         | double                      |
| `Date`, ``FirestoreTimestamp``            | timestamp                   |
| `Data`                                    | bytes                       |
| ``GeoPoint``                              | geo point                   |
| `URL`                                     | string                      |
| arrays, nested structs, dictionaries      | array, map                  |
| `nil` optionals                           | left out                    |

Conversions that would lose data throw instead: a `UInt64` above `Int64.max`, a date outside the
years 0001–9999, an `Int8` property reading 300, an `Int` reading 2.5 or NaN.

## Read

```swift
if let note = try await firestore.document("notes/x7Gk2", as: Note.self) {
    print(note.id, note.data.text, note.updateTime?.date ?? .now)
}

var token: String?
repeat {
    let page = try await firestore.documents(in: "notes", as: Note.self, pageSize: 100, pageToken: token)
    for note in page.documents { print(note.id) }
    token = page.nextPageToken
} while token != nil
```

A missing document is `nil`. Reads that fail with `UNAVAILABLE`, `RESOURCE_EXHAUSTED` and
similar transient errors are retried twice with a short pause.

## Query

``FirestoreQuery`` is built without `try`; problems such as an `in` filter with 31 values are
reported when the query runs.

```swift
let query = FirestoreQuery(collection: "notes")
    .filter("ownerID", .equal, userID)
    .filter("tags", .arrayContainsAny, ["home", "today"])
    .order(by: "createdAt", descending: true)
    .limit(20)
let notes = try await firestore.documents(matching: query, as: Note.self)
```

Comparing with `nil` or NaN becomes Firestore's `IS_NULL` and `IS_NAN` filters, which `==`
cannot express. ``FirestoreQuery/collectionGroup(_:)`` queries every collection with the same
ID. A query that combines an equality filter with an order on another field needs a composite
index; Firestore's error message contains a link that creates it.

Security Rules are not filters: a query must ask only for documents the rules allow, or the
whole query is denied. With the rules in <doc:GettingStarted>, a query for notes must filter by
`ownerID`.

## Write

```swift
let path = try await firestore.add(note, to: "notes")              // new random ID
try await firestore.set(note, at: "notes/today")                    // create or replace
try await firestore.set(["pinned": true], at: "notes/today", merge: true)
try await firestore.update("notes/today", fields: ["text": "Buy oat milk", "address.city": "Izmir"])
try await firestore.delete("notes/today")
```

``FirestoreClient/update(_:fields:transforms:)`` fails with ``FirestoreError/Code/notFound``
when the document does not exist; ``WriteBatch/create(_:at:transforms:)`` fails with
``FirestoreError/Code/alreadyExists`` when it does.

### Values computed by the server

``FieldTransform`` asks Firestore to compute a value when the write is applied:

```swift
try await firestore.add(note, to: "notes", transforms: ["createdAt": .serverTimestamp])
try await firestore.update("counters/notes", fields: [:], transforms: ["total": .increment(1)])
try await firestore.update("notes/today", fields: [:], transforms: ["tags": .arrayUnion(["urgent"])])
```

### Atomic writes

A ``WriteBatch`` holds up to 500 writes that are applied together or not at all:

```swift
var batch = WriteBatch()
try batch.create(note, at: "notes/\(FirestoreClient.newDocumentID())")
try batch.update("counters/notes", fields: [:], transforms: ["total": .increment(1)])
try batch.delete("drafts/today")
try await firestore.commit(batch)
```

Commits are never retried automatically: with a transform such as an increment, a commit whose
answer was lost may already have been applied.

## Field names and document IDs

Field paths in `update`, `filter` and `order(by:)` are dot-separated; ``FieldPath`` quotes names
that are not identifiers with backticks for you. A name that contains a dot needs the array
form: `try FieldPath(["prices", "v1.2"])`.

Document IDs may contain spaces, `?`, `#`, `:` or `%`; each is percent-encoded as one URL segment,
so it always reaches the right document.

## Limits the client checks

| Rule                                                  | Checked in                        |
| ----------------------------------------------------- | --------------------------------- |
| IDs not empty, not `.` or `..`, not `__reserved__`    | ``DocumentPath``, ``CollectionPath`` |
| IDs and field names at most 1,500 bytes               | paths, ``FieldPath``, values      |
| Document name at most 6 KiB, 100 nested collections   | paths                             |
| Maps and arrays nested at most 20 levels              | ``FirestoreValue/validate()``     |
| No array directly inside an array                     | ``FirestoreValue/validate()``     |
| At most 500 writes per commit, 10 MiB per request     | ``WriteBatch``, ``FirestoreClient`` |
| `in` and `array-contains-any` with 1–30 values, `not-in` with 1–10 | ``FirestoreQuery``   |
| Responses at most 16 MiB                              | ``URLSessionTransport``           |

## What the REST API does not have

Real-time listeners (`onSnapshot`) and the offline cache are features of the Firebase SDKs and
their gRPC streaming connection. With this package, refresh by running the query again, for
example when the app becomes active or after a write.
