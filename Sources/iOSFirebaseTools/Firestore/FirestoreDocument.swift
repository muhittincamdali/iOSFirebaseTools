import Foundation

/// A document read from Firestore: where it lives, when it changed and its decoded data.
public struct FirestoreDocument<Model>: Sendable where Model: Sendable {
    /// The document's path, such as `notes/x7Gk2…`.
    public let path: DocumentPath
    /// The decoded fields.
    public let data: Model
    public let createTime: FirestoreTimestamp?
    public let updateTime: FirestoreTimestamp?

    /// The document's ID, the last segment of ``path``.
    public var id: String { path.documentID }
}

extension FirestoreDocument: Identifiable {}
extension FirestoreDocument: Equatable where Model: Equatable {}
extension FirestoreDocument: Hashable where Model: Hashable {}

/// One page of a collection listing.
public struct FirestorePage<Model>: Sendable where Model: Sendable {
    public let documents: [FirestoreDocument<Model>]
    /// Pass it to the next listing call to get the following page; `nil` on the last page.
    public let nextPageToken: String?
}

/// The REST API's `Document`.
struct RawDocument: Codable {
    var name: String
    var fields: [String: FirestoreValue]?
    var createTime: String?
    var updateTime: String?

    func decoded<Model: Decodable & Sendable>(as type: Model.Type, root: String) throws -> FirestoreDocument<Model> {
        let prefix = root + "/"
        guard name.hasPrefix(prefix) else {
            throw MalformedResponseError(statusCode: 200, reason: "the document \(Redaction.path(name)) is not in this database")
        }
        return FirestoreDocument(
            path: try DocumentPath(String(name.dropFirst(prefix.count))),
            data: try FirestoreDecoder().decode(type, from: fields ?? [:]),
            createTime: try createTime.map(FirestoreTimestamp.init(rfc3339:)),
            updateTime: try updateTime.map(FirestoreTimestamp.init(rfc3339:))
        )
    }
}

/// A value Firestore computes on the server when a write is applied.
public enum FieldTransform: Sendable, Hashable {
    /// The time the server applies the write, for `createdAt` and `updatedAt` fields that the
    /// device's clock cannot get wrong.
    case serverTimestamp
    /// Adds to the field's number, starting from 0 when it is missing.
    case increment(FirestoreValue)
    /// Appends the values the array does not already contain.
    case arrayUnion([FirestoreValue])
    /// Removes every occurrence of the values.
    case arrayRemove([FirestoreValue])

    func body(for field: FieldPath) throws -> WriteBody.FieldTransformBody {
        var body = WriteBody.FieldTransformBody(fieldPath: field.encoded)
        switch self {
        case .serverTimestamp:
            body.setToServerValue = "REQUEST_TIME"
        case let .increment(value):
            switch value {
            case .integer:
                body.increment = value
            case let .double(amount) where amount.isFinite:
                body.increment = value
            default:
                throw ValidationError("increment of \(Redaction.label(field.encoded))", "the amount must be an integer or a finite double")
            }
        case let .arrayUnion(values):
            try FirestoreValue.array(values).validate()
            body.appendMissingElements = .init(values: values)
        case let .arrayRemove(values):
            try FirestoreValue.array(values).validate()
            body.removeAllFromArray = .init(values: values)
        }
        return body
    }
}

/// The REST API's `Write`.
struct WriteBody: Encodable {
    struct Precondition: Encodable {
        let exists: Bool
    }

    struct Mask: Encodable {
        let fieldPaths: [String]
    }

    struct ArrayValues: Encodable {
        let values: [FirestoreValue]
    }

    struct FieldTransformBody: Encodable {
        let fieldPath: String
        var setToServerValue: String?
        var increment: FirestoreValue?
        var appendMissingElements: ArrayValues?
        var removeAllFromArray: ArrayValues?
    }

    var update: RawDocument?
    var delete: String?
    var updateMask: Mask?
    var updateTransforms: [FieldTransformBody]?
    var currentDocument: Precondition?
}
