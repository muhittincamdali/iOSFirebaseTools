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
            throw MalformedResponseError(statusCode: response.statusCode, reason: reason(for: error))
        }
    }

    /// What failed and where, without the values: `JSONDecoder`'s own messages quote them.
    static func reason(for error: any Error) -> String {
        guard let error = error as? DecodingError else { return "the body is not the expected JSON" }
        let summary: String
        let context: DecodingError.Context
        switch error {
        case let .typeMismatch(_, errorContext):
            (summary, context) = ("a value has the wrong type", errorContext)
        case let .valueNotFound(_, errorContext):
            (summary, context) = ("a value is null", errorContext)
        case let .keyNotFound(key, errorContext):
            (summary, context) = ("the field \(codingKeyText(key)) is missing", errorContext)
        case let .dataCorrupted(errorContext):
            (summary, context) = ("the body is not valid JSON or a value is invalid", errorContext)
        @unknown default:
            return "the body is not the expected JSON"
        }
        guard !context.codingPath.isEmpty else { return summary }
        return summary + " at " + context.codingPath.prefix(16).map(codingKeyText).joined(separator: ".")
    }

    private static func codingKeyText(_ key: any CodingKey) -> String {
        if let index = key.intValue { return String(index) }
        let name = key.stringValue
        return Redaction.isPlain(Redaction.fold(name)) && name.unicodeScalars.count <= 64 && Redaction.isClean(name) ? name : Redaction.hidden
    }
}

/// Firebase answered with a body the client could not read.
public struct MalformedResponseError: Error, Sendable, Hashable, CustomStringConvertible {
    public let statusCode: Int
    public let reason: String

    public var description: String { "Unreadable response (HTTP \(statusCode)): \(reason)" }
}
