import Foundation

/// The contents of a `GoogleService-Info.plist` downloaded from the Firebase console, with a
/// check for the mistakes that make Firebase fail later with unclear errors.
///
/// ```swift
/// let info = try GoogleServiceInfo.inMainBundle()
/// for problem in info.problems(bundleIdentifier: Bundle.main.bundleIdentifier) {
///     assertionFailure(problem.description) // for example, a plist from another app
/// }
/// let project = try info.project()
/// ```
public struct GoogleServiceInfo: Sendable, Hashable, Decodable {
    public let apiKey: String
    public let projectID: String
    public let googleAppID: String
    public let gcmSenderID: String
    public let bundleID: String
    public let storageBucket: String?
    public let databaseURL: String?
    public let clientID: String?

    private enum CodingKeys: String, CodingKey {
        case apiKey = "API_KEY"
        case projectID = "PROJECT_ID"
        case googleAppID = "GOOGLE_APP_ID"
        case gcmSenderID = "GCM_SENDER_ID"
        case bundleID = "BUNDLE_ID"
        case storageBucket = "STORAGE_BUCKET"
        case databaseURL = "DATABASE_URL"
        case clientID = "CLIENT_ID"
    }

    /// The file name the Firebase console uses.
    public static let fileName = "GoogleService-Info.plist"
    // The console's files are under 2 KB; the cap only stops a wrong file from being read whole.
    private static let maxFileBytes = 64 * 1_024

    /// Reads a property list in XML or binary format.
    public init(data: Data) throws {
        guard data.count <= Self.maxFileBytes else {
            throw ValidationError(Self.fileName, "larger than \(Self.maxFileBytes) bytes")
        }
        self = try PropertyListDecoder().decode(Self.self, from: data)
    }

    /// Reads the file at `url`.
    public init(contentsOf url: URL) throws {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let data = try handle.read(upToCount: Self.maxFileBytes + 1) ?? Data()
        try self.init(data: data)
    }

    /// Reads `GoogleService-Info.plist` from a bundle's resources.
    public static func inMainBundle(_ bundle: Bundle = .main) throws -> GoogleServiceInfo {
        guard let url = bundle.url(forResource: "GoogleService-Info", withExtension: "plist") else {
            throw ValidationError(fileName, "not found in \(bundle.bundleURL.lastPathComponent)")
        }
        return try GoogleServiceInfo(contentsOf: url)
    }

    /// A ``FirebaseProject`` for the clients, using this file's bundle ID.
    public func project(databaseID: String = FirebaseProject.defaultDatabase) throws -> FirebaseProject {
        try FirebaseProject(projectID: projectID, apiKey: apiKey, databaseID: databaseID, bundleID: bundleID)
    }
}

extension GoogleServiceInfo {
    /// Something wrong with a `GoogleService-Info.plist`.
    public enum Problem: Sendable, Hashable, CustomStringConvertible {
        /// The file belongs to another app, a common mistake with several build configurations.
        case bundleIDMismatch(file: String, app: String)
        /// `API_KEY` is not a Google API key (`AIza` and 35 more characters).
        case malformedAPIKey
        /// `GOOGLE_APP_ID` is not `1:<project number>:ios:<hex>`.
        case malformedAppID(String)
        /// `GCM_SENDER_ID` is not the project number inside `GOOGLE_APP_ID`.
        case senderIDMismatch(senderID: String, appID: String)
        /// `PROJECT_ID` breaks Firebase's project ID rules.
        case malformedProjectID(String)

        public var description: String {
            switch self {
            case let .bundleIDMismatch(file, app):
                "BUNDLE_ID is \(Redaction.label(file)) but the app is \(Redaction.label(app)): download the plist for this app"
            case .malformedAPIKey:
                "API_KEY is not a Google API key"
            case let .malformedAppID(id):
                "GOOGLE_APP_ID \(Redaction.label(id)) is not an iOS app ID (1:<project number>:ios:<hex>)"
            case let .senderIDMismatch(sender, appID):
                "GCM_SENDER_ID \(Redaction.label(sender)) does not match the project number in GOOGLE_APP_ID \(Redaction.label(appID))"
            case let .malformedProjectID(id):
                "PROJECT_ID \(Redaction.label(id)) is not a valid project ID"
            }
        }
    }

    /// Checks the file. An empty array means no problem was found.
    ///
    /// - Parameter bundleIdentifier: The running app's bundle ID; pass `nil` to skip that check.
    public func problems(bundleIdentifier: String?) -> [Problem] {
        var found: [Problem] = []
        if let bundleIdentifier, bundleIdentifier != bundleID {
            found.append(.bundleIDMismatch(file: bundleID, app: bundleIdentifier))
        }
        if !Self.isGoogleAPIKey(apiKey) { found.append(.malformedAPIKey) }
        if let projectNumber = Self.projectNumber(inAppID: googleAppID) {
            if projectNumber != gcmSenderID {
                found.append(.senderIDMismatch(senderID: gcmSenderID, appID: googleAppID))
            }
        } else {
            found.append(.malformedAppID(googleAppID))
        }
        if (try? FirebaseProject.checkProjectID(projectID)) == nil {
            found.append(.malformedProjectID(projectID))
        }
        return found
    }

    private static func isGoogleAPIKey(_ key: String) -> Bool {
        key.count == 39 && key.hasPrefix("AIza")
            && key.allSatisfy { $0.isASCIILetterOrDigit || $0 == "-" || $0 == "_" }
    }

    /// The project number of `1:<number>:ios:<hex>`, or `nil` when the ID has another shape.
    static func projectNumber(inAppID appID: String) -> String? {
        let parts = appID.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 4, parts[0] == "1", parts[2] == "ios",
              !parts[1].isEmpty, parts[1].count <= 20, parts[1].allSatisfy(\.isASCIIDigit),
              !parts[3].isEmpty, parts[3].allSatisfy({ $0.isHexDigit && $0.isASCII }) else {
            return nil
        }
        return String(parts[1])
    }
}

// The API key is not a secret, but it is a credential name, so text forms leave it out.
extension GoogleServiceInfo: CustomStringConvertible, CustomReflectable {
    public var description: String {
        "GoogleServiceInfo(project: \(Redaction.label(projectID)), bundle: \(Redaction.label(bundleID)), apiKey: \(Redaction.hidden))"
    }

    public var customMirror: Mirror {
        Mirror(self, children: ["projectID": projectID, "bundleID": bundleID, "googleAppID": googleAppID, "apiKey": Redaction.hidden],
               displayStyle: .struct)
    }
}
