import Foundation

/// Decodes Firestore fields into `Decodable` models.
///
/// Numbers convert only when the value fits: an `Int8` property reading 300, an `Int` reading
/// 2.5 or NaN, or a `Float` reading 1e300 throws `DecodingError.typeMismatch` instead of
/// trapping or rounding. A missing field decodes as `nil` for an optional property.
public struct FirestoreDecoder: Sendable {
    public init() {}

    /// Decodes a model from a document's fields.
    public func decode<T: Decodable>(_ type: T.Type, from fields: [String: FirestoreValue]) throws -> T {
        try decode(type, from: .map(fields))
    }

    /// Decodes any `Decodable` value from one Firestore value.
    public func decode<T: Decodable>(_ type: T.Type, from value: FirestoreValue) throws -> T {
        try FirestoreValueDecoder.decode(type, from: value, codingPath: [])
    }
}

struct FirestoreValueDecoder: Decoder {
    let value: FirestoreValue
    let codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    static func decode<T: Decodable>(_ type: T.Type, from value: FirestoreValue, codingPath: [any CodingKey]) throws -> T {
        guard codingPath.count <= EncodingBox.maxCodingDepth else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Nested deeper than \(EncodingBox.maxCodingDepth) levels"))
        }
        if let special = try special(type, from: value, codingPath: codingPath) { return special }
        return try T(from: FirestoreValueDecoder(value: value, codingPath: codingPath))
    }

    /// Types with a Firestore form of their own.
    private static func special<T>(_ type: T.Type, from value: FirestoreValue, codingPath: [any CodingKey]) throws -> T? {
        let mismatch = { DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Found \(value.kind)")) }
        switch type {
        case is FirestoreValue.Type:
            return value as? T
        case is FirestoreTimestamp.Type, is Date.Type:
            guard case let .timestamp(timestamp) = value else { throw mismatch() }
            return (type is Date.Type ? timestamp.date as Any : timestamp as Any) as? T
        case is Data.Type:
            guard case let .bytes(data) = value else { throw mismatch() }
            return data as? T
        case is GeoPoint.Type:
            guard case let .geoPoint(point) = value else { throw mismatch() }
            return point as? T
        case is URL.Type:
            guard case let .string(text) = value, let url = URL(string: text) else { throw mismatch() }
            return url as? T
        default:
            return nil
        }
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard case let .map(fields) = value else {
            throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: "Found \(value.kind)"))
        }
        return KeyedDecodingContainer(KeyedValueContainer<Key>(fields: fields, codingPath: codingPath))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard case let .array(values) = value else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "Found \(value.kind)"))
        }
        return UnkeyedValueContainer(values: values, codingPath: codingPath)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        SingleValueContainer(value: value, codingPath: codingPath)
    }
}

struct KeyedValueContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let fields: [String: FirestoreValue]
    let codingPath: [any CodingKey]

    var allKeys: [Key] { fields.keys.compactMap { Key(stringValue: $0) } }

    func contains(_ key: Key) -> Bool { fields[key.stringValue] != nil }

    private func value(for key: Key) throws -> FirestoreValue {
        guard let value = fields[key.stringValue] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "No field \"\(key.stringValue)\""))
        }
        return value
    }

    func decodeNil(forKey key: Key) throws -> Bool { try value(for: key) == .null }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try FirestoreValueDecoder.decode(type, from: value(for: key), codingPath: codingPath + [key])
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        try FirestoreValueDecoder(value: value(for: key), codingPath: codingPath + [key]).container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
        try FirestoreValueDecoder(value: value(for: key), codingPath: codingPath + [key]).unkeyedContainer()
    }

    func superDecoder() throws -> any Decoder {
        FirestoreValueDecoder(value: fields["super"] ?? .null, codingPath: codingPath + [NamedKey("super")])
    }

    func superDecoder(forKey key: Key) throws -> any Decoder {
        FirestoreValueDecoder(value: fields[key.stringValue] ?? .null, codingPath: codingPath + [key])
    }
}

struct UnkeyedValueContainer: UnkeyedDecodingContainer {
    let values: [FirestoreValue]
    let codingPath: [any CodingKey]
    private(set) var currentIndex = 0

    init(values: [FirestoreValue], codingPath: [any CodingKey]) {
        self.values = values
        self.codingPath = codingPath
    }

    var count: Int? { values.count }
    var isAtEnd: Bool { currentIndex >= values.count }

    private mutating func next() throws -> (FirestoreValue, [any CodingKey]) {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any.self, .init(codingPath: codingPath, debugDescription: "The array has no more elements"))
        }
        defer { currentIndex += 1 }
        return (values[currentIndex], codingPath + [IndexKey(currentIndex)])
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd, values[currentIndex] == .null else { return false }
        currentIndex += 1
        return true
    }

    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let (value, path) = try next()
        return try FirestoreValueDecoder.decode(type, from: value, codingPath: path)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        let (value, path) = try next()
        return try FirestoreValueDecoder(value: value, codingPath: path).container(keyedBy: type)
    }

    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        let (value, path) = try next()
        return try FirestoreValueDecoder(value: value, codingPath: path).unkeyedContainer()
    }

    mutating func superDecoder() throws -> any Decoder {
        let (value, path) = try next()
        return FirestoreValueDecoder(value: value, codingPath: path)
    }
}

struct SingleValueContainer: SingleValueDecodingContainer {
    let value: FirestoreValue
    let codingPath: [any CodingKey]

    func decodeNil() -> Bool { value == .null }

    private func mismatch(_ type: Any.Type) -> DecodingError {
        .typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Found \(value.kind)"))
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case let .bool(bool) = value else { throw mismatch(type) }
        return bool
    }

    func decode(_ type: String.Type) throws -> String {
        guard case let .string(string) = value else { throw mismatch(type) }
        return string
    }

    func decode(_ type: Double.Type) throws -> Double {
        switch value {
        case let .double(double): return double
        case let .integer(integer): return Double(integer)
        default: throw mismatch(type)
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        let double = try decode(Double.self)
        let float = Float(double)
        // A finite Double too large for Float would become infinity.
        guard float.isFinite || !double.isFinite else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "\(double) does not fit in Float"))
        }
        return float
    }

    func decode(_ type: Int.Type) throws -> Int { try integer(type) }
    func decode(_ type: Int8.Type) throws -> Int8 { try integer(type) }
    func decode(_ type: Int16.Type) throws -> Int16 { try integer(type) }
    func decode(_ type: Int32.Type) throws -> Int32 { try integer(type) }
    func decode(_ type: Int64.Type) throws -> Int64 { try integer(type) }
    func decode(_ type: UInt.Type) throws -> UInt { try integer(type) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try integer(type) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try integer(type) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try integer(type) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try integer(type) }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try FirestoreValueDecoder.decode(type, from: value, codingPath: codingPath)
    }

    // `init(exactly:)` returns nil for out-of-range, fractional, NaN and infinite values, where
    // `init(_:)` would trap.
    private func integer<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        let converted: T? = switch value {
        case let .integer(integer): T(exactly: integer)
        case let .double(double): T(exactly: double)
        default: nil
        }
        guard let converted else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "\(value.kind) does not fit in \(type)"))
        }
        return converted
    }
}

extension FirestoreValue {
    /// A short description for error messages, without the value itself.
    var kind: String {
        switch self {
        case .null: "null"
        case .bool: "a Boolean"
        case let .integer(value): "the integer \(value)"
        case let .double(value): "the double \(value)"
        case .timestamp: "a timestamp"
        case .string: "a string"
        case .bytes: "bytes"
        case .reference: "a reference"
        case .geoPoint: "a geo point"
        case .array: "an array"
        case .map: "a map"
        }
    }
}
