import Foundation

/// A value was rejected before any request was sent.
///
/// The package checks project IDs, emulator addresses, document paths, field paths, query
/// limits and Firestore values against Firebase's documented rules, so a mistake fails here
/// with a clear reason instead of as a `400` from the server, or as a request to the wrong URL.
public struct ValidationError: Error, Sendable, Hashable, CustomStringConvertible {
    /// What was checked, such as `"projectID"` or `"document path"`.
    public let subject: String
    /// Why it was rejected.
    public let reason: String

    public init(_ subject: String, _ reason: String) {
        self.subject = subject
        self.reason = reason
    }

    public var description: String { "Invalid \(subject): \(reason)" }
}

/// Server error codes such as `WEAK_PASSWORD` or `HTTP 418` are shown; anything else the
/// server put in their place is hidden with its length.
enum ErrorCodeText {
    static func render(_ code: String) -> String {
        let scalars = code.unicodeScalars
        let isCode = (1...64).contains(scalars.count)
            && scalars.allSatisfy { ("A"..."Z").contains($0) || ("0"..."9").contains($0) || $0 == "_" || $0 == " " }
        return isCode ? code : "<redacted, \(scalars.count) characters>"
    }
}

/// Firebase limits the package enforces, from the Firestore and Authentication documentation.
enum Limits {
    /// Firestore: maximum size of a document ID, collection ID or field name.
    static let maxSegmentBytes = 1_500
    /// Firestore: maximum size of a document name.
    static let maxDocumentNameBytes = 6 * 1_024
    /// Firestore: maximum depth of subcollections.
    static let maxCollectionDepth = 100
    /// Firestore: maximum depth of fields in a map or array.
    static let maxFieldDepth = 20
    /// Firestore: maximum size of a document.
    static let maxDocumentBytes = 1_048_576
    /// Firestore: maximum number of writes in one commit.
    static let maxWritesPerCommit = 500
    /// Largest JSON Web Token accepted for decoding or verification.
    static let maxTokenBytes = 16 * 1_024
    /// Longest e-mail address (RFC 5321 path limit).
    static let maxEmailBytes = 254
    /// Longest password sent to Firebase Authentication.
    static let maxPasswordBytes = 4_096
}

extension String {
    var utf8Count: Int { utf8.count }

    /// `__.*__`: names Firestore reserves for itself.
    var isReservedFirestoreName: Bool {
        utf8Count >= 4 && hasPrefix("__") && hasSuffix("__")
    }
}
