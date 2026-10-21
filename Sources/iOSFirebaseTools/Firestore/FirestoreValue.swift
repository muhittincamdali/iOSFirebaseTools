import Foundation

/// A Firestore value as the REST API represents it.
///
/// Most code never builds these directly: ``FirestoreEncoder`` turns `Codable` models into
/// values and ``FirestoreDecoder`` turns them back. Queries take values as literals:
///
/// ```swift
/// let query = FirestoreQuery(collection: "notes").where("pinned", .equal, true)
/// ```
public enum FirestoreValue: Sendable, Hashable {
    case null
    case bool(Bool)
    /// A 64-bit integer. The REST API sends it as a decimal string.
    case integer(Int64)
    /// A double, including NaN and the infinities.
    case double(Double)
    case timestamp(FirestoreTimestamp)
    case string(String)
    case bytes(Data)
    /// A document name: `projects/{project}/databases/{database}/documents/{path}`.
    case reference(String)
    case geoPoint(GeoPoint)
    /// An array, which cannot directly contain another array.
    case array([FirestoreValue])
    case map([String: FirestoreValue])

    /// Throws when the value breaks one of Firestore's rules: nesting deeper than 20 levels,
    /// an array directly inside an array, or a reserved (`__name__`) or oversized map key.
    public func validate() throws {
        try validate(depth: 0, insideArray: false)
    }

    private func validate(depth: Int, insideArray: Bool) throws {
        switch self {
        case let .array(values):
            guard !insideArray else { throw ValidationError("value", "an array cannot directly contain an array") }
            guard depth < Limits.maxFieldDepth else { throw ValidationError("value", "nested deeper than \(Limits.maxFieldDepth) levels") }
            for value in values { try value.validate(depth: depth + 1, insideArray: true) }
        case let .map(fields):
            guard depth < Limits.maxFieldDepth else { throw ValidationError("value", "nested deeper than \(Limits.maxFieldDepth) levels") }
            for (key, value) in fields {
                try FieldPath.checkFieldName(key)
                try value.validate(depth: depth + 1, insideArray: false)
            }
        default:
            return
        }
    }
}

/// A latitude and longitude, Firestore's `geoPointValue`.
public struct GeoPoint: Sendable, Hashable, Codable {
    public let latitude: Double
    public let longitude: Double

    /// Throws for latitudes outside −90…90, longitudes outside −180…180, NaN and infinity.
    public init(latitude: Double, longitude: Double) throws {
        guard latitude.isFinite, longitude.isFinite, (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw ValidationError("geo point", "latitude must be −90…90 and longitude −180…180")
        }
        self.latitude = latitude
        self.longitude = longitude
    }

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }

    // proto3 JSON leaves out fields that are 0, so a missing coordinate means 0.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            latitude: try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0,
            longitude: try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        )
    }
}

extension FirestoreValue: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init(nilLiteral: ()) { self = .null }
    public init(booleanLiteral value: Bool) { self = .bool(value) }
    public init(integerLiteral value: Int64) { self = .integer(value) }
    public init(floatLiteral value: Double) { self = .double(value) }
    public init(stringLiteral value: String) { self = .string(value) }
    public init(arrayLiteral elements: FirestoreValue...) { self = .array(elements) }
    public init(dictionaryLiteral elements: (String, FirestoreValue)...) {
        self = .map(Dictionary(elements, uniquingKeysWith: { $1 }))
    }
}

extension FirestoreValue {
    /// The value of an `Encodable` model or property, encoded with ``FirestoreEncoder``.
    public init(encoding value: some Encodable) throws {
        self = try FirestoreEncoder().encodeValue(value)
    }

    /// `true` for `.double(.nan)`, which queries must match with `isNaN` rather than `==`.
    var isNaN: Bool {
        if case let .double(value) = self { value.isNaN } else { false }
    }
}
