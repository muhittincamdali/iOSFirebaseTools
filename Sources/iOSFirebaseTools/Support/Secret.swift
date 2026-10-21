import Foundation

/// A token or other credential that never prints in full.
///
/// `print`, string interpolation, `dump`, `debugPrint` and the debugger show only the length:
///
/// ```swift
/// let token = Secret("eyJhbGciOiJSUzI1NiIs…")
/// print(token) // Secret(redacted, 873 characters)
/// ```
///
/// Read ``revealed`` only where the value leaves the process on purpose, such as an
/// `Authorization` header. `Codable` stores the full value so a session can be saved in the
/// keychain; do not encode a `Secret` into logs or analytics.
public struct Secret: Sendable, Hashable, Codable {
    /// The full value.
    public let revealed: String

    /// Wraps a value.
    public init(_ value: String) {
        self.revealed = value
    }

    public init(from decoder: any Decoder) throws {
        revealed = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(revealed)
    }

    /// `true` when the value is the empty string.
    public var isEmpty: Bool { revealed.isEmpty }
}

extension Secret: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var description: String {
        "Secret(redacted, \(revealed.count) characters)"
    }

    public var debugDescription: String { description }

    /// An empty mirror, so `dump` and the debugger cannot list the stored value.
    public var customMirror: Mirror {
        Mirror(self, children: [], displayStyle: .struct)
    }
}
