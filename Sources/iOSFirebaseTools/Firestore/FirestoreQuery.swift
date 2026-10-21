import Foundation

/// A query over one collection, or over every collection with the same ID.
///
/// ```swift
/// let recent = FirestoreQuery(collection: "notes")
///     .filter("ownerID", .equal, userID)
///     .order(by: "createdAt", descending: true)
///     .limit(20)
/// let notes = try await firestore.documents(matching: recent, as: Note.self)
/// ```
///
/// Building a query never throws; values that cannot be encoded and limits out of range are
/// reported when the query runs. Comparing with `nil` or NaN becomes Firestore's `IS_NULL` and
/// `IS_NAN` filters, which `==` cannot express.
public struct FirestoreQuery: Sendable {
    /// A comparison in a filter.
    public enum Operator: String, Sendable {
        case lessThan = "LESS_THAN"
        case lessThanOrEqual = "LESS_THAN_OR_EQUAL"
        case greaterThan = "GREATER_THAN"
        case greaterThanOrEqual = "GREATER_THAN_OR_EQUAL"
        case equal = "EQUAL"
        case notEqual = "NOT_EQUAL"
        case arrayContains = "ARRAY_CONTAINS"
        /// The field equals one of up to 30 values.
        case `in` = "IN"
        /// The array field contains one of up to 30 values.
        case arrayContainsAny = "ARRAY_CONTAINS_ANY"
        /// The field equals none of up to 10 values.
        case notIn = "NOT_IN"
    }

    struct Filter: Sendable {
        let field: FieldPath
        let op: Operator
        let value: FirestoreValue
    }

    struct Order: Sendable {
        let field: FieldPath
        let descending: Bool
    }

    let collectionPath: String
    let allDescendants: Bool
    private(set) var filters: [Filter] = []
    private(set) var orders: [Order] = []
    private(set) var limitCount: Int?
    private(set) var problems: [String] = []

    /// A query over the collection at `collection`, such as `"notes"` or `"users/ada/notes"`.
    public init(collection: String) {
        collectionPath = collection
        allDescendants = false
    }

    /// A query over every collection named `collectionID`, at any depth. Firestore needs a
    /// collection group index for filtered or ordered group queries.
    public static func collectionGroup(_ collectionID: String) -> FirestoreQuery {
        FirestoreQuery(groupID: collectionID)
    }

    private init(groupID: String) {
        collectionPath = groupID
        allDescendants = true
    }

    /// Keeps documents whose `field` compares to `value` with `op`. Several filters must all match.
    public func filter(_ field: FieldPath, _ op: Operator, _ value: some Encodable) -> FirestoreQuery {
        var copy = self
        do {
            copy.filters.append(Filter(field: field, op: op, value: try FirestoreValue(encoding: value)))
        } catch {
            copy.problems.append("the value for \(Redaction.label(field.encoded)) cannot be encoded: \(EncodingErrorText.reason(error))")
        }
        return copy
    }

    /// Sorts by `field`. Documents without the field are left out of an ordered query.
    public func order(by field: FieldPath, descending: Bool = false) -> FirestoreQuery {
        var copy = self
        copy.orders.append(Order(field: field, descending: descending))
        return copy
    }

    /// Returns at most `count` documents; `count` must be 1 or more.
    public func limit(_ count: Int) -> FirestoreQuery {
        var copy = self
        copy.limitCount = count
        return copy
    }
}

// MARK: - Request body

extension FirestoreQuery {
    /// The document whose subcollections the query runs over, and the collection ID.
    func target() throws -> (parent: DocumentPath?, collectionID: String) {
        if allDescendants {
            _ = try CollectionPath(collectionPath)
            guard !collectionPath.contains("/") else {
                throw ValidationError("collection group \(Redaction.path(collectionPath))", "a collection group is one collection ID")
            }
            return (nil, collectionPath)
        }
        let path = try CollectionPath(collectionPath)
        return (path.parent, path.collectionID)
    }

    func structuredQuery(collectionID: String) throws -> StructuredQuery {
        if let problem = problems.first { throw ValidationError("query", problem) }
        if let limitCount, !(1...Int(Int32.max)).contains(limitCount) {
            throw ValidationError("query limit", "must be from 1 to \(Int32.max)")
        }
        let encodedFilters = try filters.map(Self.encode)
        let whereClause: StructuredQuery.Filter? = switch encodedFilters.count {
        case 0: nil
        case 1: encodedFilters[0]
        default: StructuredQuery.Filter(compositeFilter: .init(op: "AND", filters: encodedFilters))
        }
        return StructuredQuery(
            from: [.init(collectionId: collectionID, allDescendants: allDescendants)],
            where: whereClause,
            orderBy: orders.isEmpty ? nil : orders.map {
                .init(field: .init(fieldPath: $0.field.encoded), direction: $0.descending ? "DESCENDING" : "ASCENDING")
            },
            limit: limitCount
        )
    }

    private static func encode(_ filter: Filter) throws -> StructuredQuery.Filter {
        let field = StructuredQuery.FieldReference(fieldPath: filter.field.encoded)
        if filter.value == .null || filter.value.isNaN {
            let isNull = filter.value == .null
            switch filter.op {
            case .equal: return .init(unaryFilter: .init(op: isNull ? "IS_NULL" : "IS_NAN", field: field))
            case .notEqual: return .init(unaryFilter: .init(op: isNull ? "IS_NOT_NULL" : "IS_NOT_NAN", field: field))
            default: throw ValidationError("filter on \(Redaction.label(filter.field.encoded))", "null and NaN can only be compared with .equal or .notEqual")
            }
        }
        try checkListOperand(filter)
        return .init(fieldFilter: .init(field: field, op: filter.op.rawValue, value: filter.value))
    }

    private static func checkListOperand(_ filter: Filter) throws {
        let maximum: Int
        switch filter.op {
        case .in, .arrayContainsAny: maximum = 30
        case .notIn: maximum = 10
        default: return
        }
        guard case let .array(values) = filter.value, (1...maximum).contains(values.count) else {
            throw ValidationError("filter on \(Redaction.label(filter.field.encoded))", "\(filter.op.rawValue) needs an array of 1–\(maximum) values")
        }
    }
}

/// The REST API's `StructuredQuery`.
struct StructuredQuery: Encodable {
    struct CollectionSelector: Encodable {
        let collectionId: String
        let allDescendants: Bool
    }

    struct FieldReference: Encodable {
        let fieldPath: String
    }

    struct FieldFilter: Encodable {
        let field: FieldReference
        let op: String
        let value: FirestoreValue
    }

    struct UnaryFilter: Encodable {
        let op: String
        let field: FieldReference
    }

    struct CompositeFilter: Encodable {
        let op: String
        let filters: [Filter]
    }

    struct Filter: Encodable {
        var fieldFilter: FieldFilter?
        var unaryFilter: UnaryFilter?
        var compositeFilter: CompositeFilter?
    }

    struct Order: Encodable {
        let field: FieldReference
        let direction: String
    }

    let from: [CollectionSelector]
    let `where`: Filter?
    let orderBy: [Order]?
    let limit: Int?
}
