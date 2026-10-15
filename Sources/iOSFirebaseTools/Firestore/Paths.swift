import Foundation

/// The path of a document, such as `users/ada/notes/n1`: an even number of segments.
public struct DocumentPath: Sendable, Hashable, CustomStringConvertible {
    public let segments: [String]

    /// Parses a slash-separated path and checks Firestore's rules for IDs: not empty, not `.`
    /// or `..`, not `__reserved__`, at most 1,500 bytes, and at most 6 KiB in total.
    public init(_ path: String) throws {
        let segments = try PathRules.split(path, what: "document path")
        guard segments.count.isMultiple(of: 2) else {
            throw ValidationError("document path \"\(path.prefix(80))\"", "a document path has an even number of segments")
        }
        self.segments = segments
    }

    init(validated segments: [String]) {
        self.segments = segments
    }

    /// The document's ID, the last segment.
    public var documentID: String { segments[segments.count - 1] }

    /// The collection the document is in.
    public var collection: CollectionPath { CollectionPath(validated: Array(segments.dropLast())) }

    /// A subcollection of this document.
    public func collection(_ id: String) throws -> CollectionPath {
        try CollectionPath((segments + [id]).joined(separator: "/"))
    }

    public var description: String { segments.joined(separator: "/") }
}

/// The path of a collection, such as `users` or `users/ada/notes`: an odd number of segments.
public struct CollectionPath: Sendable, Hashable, CustomStringConvertible {
    public let segments: [String]

    public init(_ path: String) throws {
        let segments = try PathRules.split(path, what: "collection path")
        guard !segments.count.isMultiple(of: 2) else {
            throw ValidationError("collection path \"\(path.prefix(80))\"", "a collection path has an odd number of segments")
        }
        self.segments = segments
    }

    init(validated segments: [String]) {
        self.segments = segments
    }

    /// The collection's ID, the last segment.
    public var collectionID: String { segments[segments.count - 1] }

    /// The document that holds this collection, or `nil` for a top-level collection.
    public var parent: DocumentPath? {
        segments.count > 1 ? DocumentPath(validated: Array(segments.dropLast())) : nil
    }

    /// A document in this collection.
    public func document(_ id: String) throws -> DocumentPath {
        try DocumentPath((segments + [id]).joined(separator: "/"))
    }

    public var description: String { segments.joined(separator: "/") }
}

enum PathRules {
    static func split(_ path: String, what: String) throws -> [String] {
        let invalid = { (reason: String) in ValidationError("\(what) \"\(path.prefix(80))\"", reason) }
        guard path.utf8Count <= Limits.maxDocumentNameBytes else { throw invalid("longer than 6 KiB") }
        let segments = path.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard segments.count <= Limits.maxCollectionDepth * 2 else { throw invalid("deeper than 100 collections") }
        for segment in segments {
            if segment.isEmpty { throw invalid("an ID is empty (check for a leading, trailing or double '/')") }
            if segment == "." || segment == ".." { throw invalid("an ID cannot be '.' or '..'") }
            if segment.isReservedFirestoreName { throw invalid("IDs of the form __name__ are reserved") }
            if segment.utf8Count > Limits.maxSegmentBytes { throw invalid("an ID is longer than 1,500 bytes") }
        }
        return segments
    }

    /// A path segment for a URL: everything except unreserved characters is percent-encoded,
    /// so an ID such as `a?b`, `a#b`, `x:commit` or `%2F` stays one segment of the right document.
    static func urlSegment(_ segment: String) -> String {
        segment.addingPercentEncoding(withAllowedCharacters: unreserved) ?? segment
    }

    private static let unreserved = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

/// A field in a document, such as `address.city`, with the quoting Firestore needs for names
/// that are not plain identifiers.
public struct FieldPath: Sendable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    /// The field names from the top of the document down.
    public let names: [String]

    /// The document's ID, for ordering or filtering by it.
    public static let documentID = FieldPath(validated: ["__name__"])

    /// Field names given one by one, so they may contain dots or any other character.
    public init(_ names: [String]) throws {
        guard !names.isEmpty else { throw ValidationError("field path", "it has no field names") }
        for name in names { try Self.checkFieldName(name) }
        self.names = names
        guard encoded.utf8Count <= Limits.maxSegmentBytes else {
            throw ValidationError("field path", "longer than 1,500 bytes")
        }
    }

    /// A dot-separated path of field names: `"address.city"`. Use ``init(_:)`` with an array
    /// for names that contain a dot.
    public init(dotted path: String) throws {
        try self.init(path.split(separator: ".", omittingEmptySubsequences: false).map(String.init))
    }

    /// A dot-separated path from a string literal, such as `"createdAt"`. The literal is checked
    /// when the program runs and an invalid one (`"a..b"`) stops it, like an out-of-range array
    /// index; use ``init(dotted:)`` for paths built at runtime.
    public init(stringLiteral value: String) {
        do {
            try self.init(dotted: value)
        } catch {
            preconditionFailure("\(error)")
        }
    }

    private init(validated names: [String]) {
        self.names = names
    }

    /// The path as Firestore reads it: plain names as they are, others in backticks with
    /// `` ` `` and `\` escaped, joined by dots.
    public var encoded: String {
        names.map { name in
            if Self.isSimple(name) { return name }
            let escaped = name.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "`", with: "\\`")
            return "`\(escaped)`"
        }.joined(separator: ".")
    }

    public var description: String { encoded }

    static func checkFieldName(_ name: String) throws {
        guard !name.isEmpty else { throw ValidationError("field name", "it is empty") }
        guard name.utf8Count <= Limits.maxSegmentBytes else { throw ValidationError("field name", "longer than 1,500 bytes") }
        guard !name.isReservedFirestoreName else {
            throw ValidationError("field name \"\(name.prefix(40))\"", "names of the form __name__ are reserved")
        }
    }

    private static func isSimple(_ name: String) -> Bool {
        guard let first = name.unicodeScalars.first, !("0"..."9").contains(first) else { return false }
        return name.unicodeScalars.allSatisfy { $0.isASCII && ($0.properties.isAlphabetic || ("0"..."9").contains($0) || $0 == "_") }
    }
}
