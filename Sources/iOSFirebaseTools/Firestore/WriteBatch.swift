import Foundation

/// Writes that Firestore applies together or not at all, with ``FirestoreClient/commit(_:)``.
///
/// ```swift
/// var batch = WriteBatch()
/// try batch.update("counters/notes", fields: [:], transforms: ["total": .increment(1)])
/// try batch.create(note, at: "notes/\(id)", transforms: ["createdAt": .serverTimestamp])
/// try await firestore.commit(batch)
/// ```
///
/// A batch holds at most 500 writes.
public struct WriteBatch: Sendable {
    enum Write: Sendable {
        case update(path: DocumentPath, fields: [String: FirestoreValue], mask: [FieldPath]?,
                    transforms: [(FieldPath, FieldTransform)], exists: Bool?)
        case delete(path: DocumentPath)

        var path: DocumentPath {
            switch self {
            case let .update(path, _, _, _, _), let .delete(path): path
            }
        }
    }

    private(set) var writes: [Write] = []

    public init() {}

    /// The number of writes.
    public var count: Int { writes.count }

    /// Creates the document; the commit fails with ``FirestoreError/Code/alreadyExists`` if it exists.
    public mutating func create(_ value: some Encodable, at path: String, transforms: [FieldPath: FieldTransform] = [:]) throws {
        try append(.update(path: DocumentPath(path), fields: FirestoreEncoder().encode(value), mask: nil,
                           transforms: Self.sorted(transforms), exists: false))
    }

    /// Writes the document, replacing it if it exists. With `merge`, only the fields in `value`
    /// change and the others stay.
    public mutating func set(_ value: some Encodable, at path: String, merge: Bool = false, transforms: [FieldPath: FieldTransform] = [:]) throws {
        let fields = try FirestoreEncoder().encode(value)
        let mask = merge ? try Self.leafPaths(of: fields, under: []) : nil
        try append(.update(path: DocumentPath(path), fields: fields, mask: mask, transforms: Self.sorted(transforms), exists: nil))
    }

    /// Changes the listed fields of an existing document; the commit fails with
    /// ``FirestoreError/Code/notFound`` if it does not exist. Nested fields are named by path:
    /// `["address.city": "Izmir"]`.
    public mutating func update(_ path: String, fields: [FieldPath: FirestoreValue], transforms: [FieldPath: FieldTransform] = [:]) throws {
        try Self.checkDisjoint(Array(fields.keys) + Array(transforms.keys))
        for value in fields.values { try value.validate() }
        try append(.update(path: DocumentPath(path), fields: try Self.nest(fields),
                           mask: fields.keys.sorted { $0.encoded < $1.encoded },
                           transforms: Self.sorted(transforms), exists: true))
    }

    /// Deletes the document. Deleting a missing document succeeds.
    public mutating func delete(_ path: String) throws {
        try append(.delete(path: DocumentPath(path)))
    }

    private mutating func append(_ write: Write) throws {
        guard writes.count < Limits.maxWritesPerCommit else {
            throw ValidationError("batch", "holds at most \(Limits.maxWritesPerCommit) writes")
        }
        writes.append(write)
    }

    // MARK: - Request body

    func bodies(root: String) throws -> [WriteBody] {
        try writes.map { write in
            switch write {
            case let .delete(path):
                return WriteBody(delete: "\(root)/\(path)")
            case let .update(path, fields, mask, transforms, exists):
                var body = WriteBody(update: RawDocument(name: "\(root)/\(path)", fields: fields))
                body.updateMask = mask.map { WriteBody.Mask(fieldPaths: $0.map(\.encoded)) }
                if !transforms.isEmpty {
                    body.updateTransforms = try transforms.map { try $0.1.body(for: $0.0) }
                }
                body.currentDocument = exists.map(WriteBody.Precondition.init)
                return body
            }
        }
    }

    // MARK: - Field paths

    private static func sorted(_ transforms: [FieldPath: FieldTransform]) -> [(FieldPath, FieldTransform)] {
        transforms.sorted { $0.key.encoded < $1.key.encoded }.map { ($0.key, $0.value) }
    }

    /// Every path to a value that is not a non-empty map, for a merge's update mask.
    static func leafPaths(of fields: [String: FirestoreValue], under prefix: [String]) throws -> [FieldPath] {
        var paths: [FieldPath] = []
        for (name, value) in fields.sorted(by: { $0.key < $1.key }) {
            if case let .map(nested) = value, !nested.isEmpty {
                paths += try leafPaths(of: nested, under: prefix + [name])
            } else {
                paths.append(try FieldPath(prefix + [name]))
            }
        }
        return paths
    }

    /// Firestore rejects a write that names a field and one inside it, such as `a` and `a.b`.
    static func checkDisjoint(_ paths: [FieldPath]) throws {
        let all = Set(paths.map(\.names))
        for path in paths where path.names.count > 1 {
            for length in 1..<path.names.count where all.contains(Array(path.names.prefix(length))) {
                throw ValidationError("field paths", "\(Redaction.label(path.encoded)) is inside another field of the same write")
            }
        }
        guard all.count == paths.count else { throw ValidationError("field paths", "a field is named twice") }
    }

    /// Turns `["address.city": "Izmir"]` into `["address": ["city": "Izmir"]]`.
    static func nest(_ fields: [FieldPath: FirestoreValue]) throws -> [String: FirestoreValue] {
        var root: [String: FirestoreValue] = [:]
        for (path, value) in fields {
            insert(value, at: path.names[...], into: &root)
        }
        try FirestoreValue.map(root).validate()
        return root
    }

    private static func insert(_ value: FirestoreValue, at names: ArraySlice<String>, into map: inout [String: FirestoreValue]) {
        guard let first = names.first else { return }
        if names.count == 1 {
            map[first] = value
            return
        }
        var nested: [String: FirestoreValue] = if case let .map(existing)? = map[first] { existing } else { [:] }
        insert(value, at: names.dropFirst(), into: &nested)
        map[first] = .map(nested)
    }
}
