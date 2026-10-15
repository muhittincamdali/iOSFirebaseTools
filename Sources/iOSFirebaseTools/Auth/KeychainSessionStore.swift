import Foundation
import Security

/// A ``SessionStore`` that keeps the session in the keychain, so the user stays signed in
/// across launches.
///
/// The item is a generic password readable after the first unlock and never synced to other
/// devices (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`), which lets background tasks
/// refresh the token while keeping the refresh token on this device.
public struct KeychainSessionStore: SessionStore {
    /// `kSecAttrService` of the item.
    public let service: String
    /// `kSecAttrAccount` of the item.
    public let account: String
    /// `kSecAttrAccessGroup`, to share the session with an app extension or App Clip.
    public let accessGroup: String?

    // A session is under 4 KB; anything larger in the item is not one of ours.
    private static let maxItemBytes = 64 * 1_024

    public init(service: String = "iOSFirebaseTools.session", account: String = "default", accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }

    public func load() async throws -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        try Self.check(status)
        guard let data = result as? Data, data.count <= Self.maxItemBytes,
              let session = try? JSONDecoder().decode(AuthSession.self, from: data) else {
            // An unreadable item (an older format, or damage) is treated as signed out.
            try await clear()
            return nil
        }
        return session
    }

    public func save(_ session: AuthSession) async throws {
        let data = try JSONEncoder().encode(session)
        let update: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        if status != errSecItemNotFound {
            try Self.check(status)
            return
        }
        var item = baseQuery
        item.merge(update) { $1 }
        try Self.check(SecItemAdd(item as CFDictionary, nil))
    }

    public func clear() async throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        if status != errSecItemNotFound { try Self.check(status) }
    }

    private var baseQuery: [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        if let accessGroup { query[kSecAttrAccessGroup as String] = accessGroup }
        return query
    }

    private static func check(_ status: OSStatus) throws {
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
}

/// A keychain call failed.
public struct KeychainError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The `OSStatus` returned by the Security framework.
    public let status: OSStatus

    public var description: String {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "unknown error"
        return "KeychainError(\(status)): \(message)"
    }
}
