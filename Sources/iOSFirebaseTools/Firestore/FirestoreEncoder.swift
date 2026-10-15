import Foundation

/// Encodes `Encodable` models into Firestore fields.
///
/// `Date` becomes a timestamp, `Data` bytes, ``GeoPoint`` a geo point, `URL` a string and
/// integers 64-bit integers. A `UInt64` above `Int64.max` throws instead of wrapping, and a
/// date outside the years 0001–9999 throws instead of trapping. Optional properties that are
/// `nil` are left out, as `JSONEncoder` does.
///
/// ```swift
/// struct Note: Codable {
///     var text: String
///     var createdAt: Date
/// }
/// let fields = try FirestoreEncoder().encode(Note(text: "Buy milk", createdAt: .now))
/// ```
public struct FirestoreEncoder: Sendable {
    public init() {}

    /// Encodes a model whose top level is keyed (a struct, class or dictionary) into the
    /// fields of a document.
    public func encode(_ value: some Encodable) throws -> [String: FirestoreValue] {
        guard case let .map(fields) = try encodeValue(value) else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "A document must encode as a keyed container"))
        }
        return fields
    }

    /// Encodes any `Encodable` value, such as a property or an array, into one Firestore value.
    public func encodeValue(_ value: some Encodable) throws -> FirestoreValue {
        let encoded = try EncodingBox.encode(value, codingPath: []).resolve()
        do {
            try encoded.validate()
        } catch let error as ValidationError {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: error.description, underlyingError: error))
        }
        return encoded
    }
}

/// One value being encoded. Containers fill it in place, so nested containers can keep
/// writing after they are returned.
final class EncodingBox {
    var single: FirestoreValue?
    var map: [String: EncodingBox]?
    var array: [EncodingBox]?

    /// Model types nest far less; the cap turns a reference cycle into an error instead of a
    /// stack overflow.
    static let maxCodingDepth = 64

    init(_ single: FirestoreValue? = nil) {
        self.single = single
    }

    func resolve() -> FirestoreValue {
        if let map { return .map(map.mapValues { $0.resolve() }) }
        if let array { return .array(array.map { $0.resolve() }) }
        return single ?? .null
    }

    static func encode<T: Encodable>(_ value: T, codingPath: [any CodingKey]) throws -> EncodingBox {
        guard codingPath.count <= maxCodingDepth else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Nested deeper than \(maxCodingDepth) levels"))
        }
        if let special = try special(value, codingPath: codingPath) { return EncodingBox(special) }
        let box = EncodingBox()
        try value.encode(to: FirestoreValueEncoder(box: box, codingPath: codingPath))
        return box
    }

    /// Types with a Firestore form of their own.
    private static func special(_ value: some Encodable, codingPath: [any CodingKey]) throws -> FirestoreValue? {
        switch value {
        case let value as FirestoreValue: return value
        case let value as FirestoreTimestamp: return .timestamp(value)
        case let value as Date:
            do {
                return .timestamp(try FirestoreTimestamp(value))
            } catch {
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "\(error)"))
            }
        case let value as Data: return .bytes(value)
        case let value as GeoPoint: return .geoPoint(value)
        case let value as URL: return .string(value.absoluteString)
        case let value as Decimal: return .double(NSDecimalNumber(decimal: value).doubleValue)
        default: return nil
        }
    }

    static func integer<T: BinaryInteger>(_ value: T, codingPath: [any CodingKey]) throws -> FirestoreValue {
        guard let exact = Int64(exactly: value) else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "\(value) does not fit in Firestore's 64-bit integers"))
        }
        return .integer(exact)
    }
}

struct FirestoreValueEncoder: Encoder {
    let box: EncodingBox
    let codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        if box.map == nil { box.map = [:] }
        return KeyedEncodingContainer(KeyedBoxContainer<Key>(box: box, codingPath: codingPath))
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        if box.array == nil { box.array = [] }
        return UnkeyedBoxContainer(box: box, codingPath: codingPath)
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        SingleBoxContainer(box: box, codingPath: codingPath)
    }
}

struct KeyedBoxContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let box: EncodingBox
    let codingPath: [any CodingKey]

    private func set(_ child: EncodingBox, for key: Key) {
        box.map?[key.stringValue] = child
    }

    mutating func encodeNil(forKey key: Key) throws { set(EncodingBox(.null), for: key) }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        set(try EncodingBox.encode(value, codingPath: codingPath + [key]), for: key)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let child = EncodingBox()
        set(child, for: key)
        return FirestoreValueEncoder(box: child, codingPath: codingPath + [key]).container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        let child = EncodingBox()
        set(child, for: key)
        return FirestoreValueEncoder(box: child, codingPath: codingPath + [key]).unkeyedContainer()
    }

    mutating func superEncoder() -> any Encoder {
        let child = EncodingBox()
        box.map?["super"] = child
        return FirestoreValueEncoder(box: child, codingPath: codingPath + [NamedKey("super")])
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        let child = EncodingBox()
        set(child, for: key)
        return FirestoreValueEncoder(box: child, codingPath: codingPath + [key])
    }
}

struct UnkeyedBoxContainer: UnkeyedEncodingContainer {
    let box: EncodingBox
    let codingPath: [any CodingKey]
    var count: Int { box.array?.count ?? 0 }

    private var nextKey: IndexKey { IndexKey(count) }

    mutating func encodeNil() throws { box.array?.append(EncodingBox(.null)) }

    mutating func encode<T: Encodable>(_ value: T) throws {
        // Encode first: reading `count` inside the append would overlap with the array's write access.
        let child = try EncodingBox.encode(value, codingPath: codingPath + [nextKey])
        box.array?.append(child)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        let child = EncodingBox()
        let path = codingPath + [nextKey]
        box.array?.append(child)
        return FirestoreValueEncoder(box: child, codingPath: path).container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        let child = EncodingBox()
        let path = codingPath + [nextKey]
        box.array?.append(child)
        return FirestoreValueEncoder(box: child, codingPath: path).unkeyedContainer()
    }

    mutating func superEncoder() -> any Encoder {
        let child = EncodingBox()
        let path = codingPath + [nextKey]
        box.array?.append(child)
        return FirestoreValueEncoder(box: child, codingPath: path)
    }
}

struct SingleBoxContainer: SingleValueEncodingContainer {
    let box: EncodingBox
    let codingPath: [any CodingKey]

    mutating func encodeNil() throws { box.single = .null }
    mutating func encode(_ value: Bool) throws { box.single = .bool(value) }
    mutating func encode(_ value: String) throws { box.single = .string(value) }
    mutating func encode(_ value: Double) throws { box.single = .double(value) }
    mutating func encode(_ value: Float) throws { box.single = .double(Double(value)) }
    mutating func encode(_ value: Int) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: Int8) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: Int16) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: Int32) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: Int64) throws { box.single = .integer(value) }
    mutating func encode(_ value: UInt) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: UInt8) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: UInt16) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: UInt32) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }
    mutating func encode(_ value: UInt64) throws { box.single = try EncodingBox.integer(value, codingPath: codingPath) }

    mutating func encode<T: Encodable>(_ value: T) throws {
        let encoded = try EncodingBox.encode(value, codingPath: codingPath)
        box.single = encoded.single
        box.map = encoded.map
        box.array = encoded.array
    }
}

/// A coding key with a fixed name, for `super`.
struct NamedKey: CodingKey {
    let stringValue: String
    var intValue: Int? { nil }

    init(_ name: String) { stringValue = name }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { return nil }
}

/// The coding key of an array element.
struct IndexKey: CodingKey {
    let intValue: Int?
    var stringValue: String { "Index \(intValue ?? 0)" }

    init(_ index: Int) { intValue = index }
    init?(stringValue: String) { return nil }
    init?(intValue: Int) { self.intValue = intValue }
}
