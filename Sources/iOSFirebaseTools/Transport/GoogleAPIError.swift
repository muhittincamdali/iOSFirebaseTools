import Foundation

/// The `{"error": {...}}` body that Google APIs return with a failed request.
struct GoogleAPIErrorBody: Decodable {
    struct Detail: Decodable {
        let code: Int?
        let message: String?
        let status: String?
    }

    let error: Detail

    static func decode(_ data: Data) -> Detail? {
        (try? JSONDecoder().decode(GoogleAPIErrorBody.self, from: data))?.error
    }
}

/// JSON helpers shared by the clients.
enum JSONBody {
    static func encode(_ value: some Encodable) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from response: HTTPResponse) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: response.body)
        } catch {
            throw MalformedResponseError(statusCode: response.statusCode, reason: String(describing: error))
        }
    }
}

/// Firebase answered with a body the client could not read.
public struct MalformedResponseError: Error, Sendable, Hashable, CustomStringConvertible {
    public let statusCode: Int
    public let reason: String

    public var description: String { "Unreadable response (HTTP \(statusCode)): \(reason)" }
}
