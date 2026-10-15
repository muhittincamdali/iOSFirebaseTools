import Foundation

/// The REST API's JSON form of a value: an object with exactly one key, such as
/// `{"integerValue": "42"}` or `{"mapValue": {"fields": {...}}}`.
extension FirestoreValue: Codable {
    private enum Key: String, CodingKey {
        case nullValue, booleanValue, integerValue, doubleValue, timestampValue, stringValue
        case bytesValue, referenceValue, geoPointValue, arrayValue, mapValue
    }

    private struct ArrayBody: Codable {
        var values: [FirestoreValue]?
    }

    private struct MapBody: Codable {
        var fields: [String: FirestoreValue]?
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let keys = container.allKeys
        guard keys.count == 1, let key = keys.first else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                debugDescription: "A Firestore value has exactly one known type key, found \(keys.count)"))
        }
        self = try Self.decode(key, from: container)
    }

    private static func decode(_ key: Key, from container: KeyedDecodingContainer<Key>) throws -> FirestoreValue {
        switch key {
        case .nullValue: return .null
        case .booleanValue: return .bool(try container.decode(Bool.self, forKey: key))
        case .integerValue: return .integer(try decodeInteger(container))
        case .doubleValue: return .double(try decodeDouble(container))
        case .timestampValue:
            let text = try container.decode(String.self, forKey: key)
            do {
                return .timestamp(try FirestoreTimestamp(rfc3339: text))
            } catch {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: String(describing: error))
            }
        case .stringValue: return .string(try container.decode(String.self, forKey: key))
        case .bytesValue:
            let text = try container.decode(String.self, forKey: key)
            // proto3 JSON accepts standard and URL-safe base64, padded or not.
            guard let data = Data(base64Encoded: text) ?? Base64URL.decode(Substring(text.replacingOccurrences(of: "=", with: ""))) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "bytesValue is not base64")
            }
            return .bytes(data)
        case .referenceValue: return .reference(try container.decode(String.self, forKey: key))
        case .geoPointValue: return .geoPoint(try container.decode(GeoPoint.self, forKey: key))
        case .arrayValue: return .array(try container.decode(ArrayBody.self, forKey: key).values ?? [])
        case .mapValue: return .map(try container.decode(MapBody.self, forKey: key).fields ?? [:])
        }
    }

    // A decimal string in Int64's range. Int64(String) returns nil instead of trapping on
    // overflow; numbers are accepted too, but only when they are exact integers.
    private static func decodeInteger(_ container: KeyedDecodingContainer<Key>) throws -> Int64 {
        if let text = try? container.decode(String.self, forKey: .integerValue) {
            guard text.utf8.count <= 20, let value = Int64(text) else {
                throw DecodingError.dataCorruptedError(forKey: .integerValue, in: container,
                    debugDescription: "integerValue \"\(text.prefix(24))\" is not a 64-bit integer")
            }
            return value
        }
        return try container.decode(Int64.self, forKey: .integerValue)
    }

    // proto3 JSON writes NaN and the infinities as strings.
    private static func decodeDouble(_ container: KeyedDecodingContainer<Key>) throws -> Double {
        if let text = try? container.decode(String.self, forKey: .doubleValue) {
            switch text {
            case "NaN": return .nan
            case "Infinity": return .infinity
            case "-Infinity": return -.infinity
            default:
                throw DecodingError.dataCorruptedError(forKey: .doubleValue, in: container,
                    debugDescription: "doubleValue \"\(text.prefix(24))\" is not a number")
            }
        }
        return try container.decode(Double.self, forKey: .doubleValue)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .null: try container.encodeNil(forKey: .nullValue)
        case let .bool(value): try container.encode(value, forKey: .booleanValue)
        case let .integer(value): try container.encode(String(value), forKey: .integerValue)
        case let .double(value):
            if value.isNaN {
                try container.encode("NaN", forKey: .doubleValue)
            } else if value.isInfinite {
                try container.encode(value > 0 ? "Infinity" : "-Infinity", forKey: .doubleValue)
            } else {
                try container.encode(value, forKey: .doubleValue)
            }
        case let .timestamp(value): try container.encode(value.rfc3339, forKey: .timestampValue)
        case let .string(value): try container.encode(value, forKey: .stringValue)
        case let .bytes(value): try container.encode(value.base64EncodedString(), forKey: .bytesValue)
        case let .reference(value): try container.encode(value, forKey: .referenceValue)
        case let .geoPoint(value): try container.encode(value, forKey: .geoPointValue)
        case let .array(values): try container.encode(ArrayBody(values: values), forKey: .arrayValue)
        case let .map(fields): try container.encode(MapBody(fields: fields), forKey: .mapValue)
        }
    }
}
