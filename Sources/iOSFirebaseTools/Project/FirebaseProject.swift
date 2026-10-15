import Foundation

/// The Firebase project the clients talk to: its ID, Web API key and, optionally, the Local
/// Emulator Suite.
///
/// ```swift
/// // From the GoogleService-Info.plist in the app bundle:
/// let project = try GoogleServiceInfo.inMainBundle().project()
///
/// // Or by hand, here against the emulators started with `firebase emulators:start`:
/// let local = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
///     .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
/// ```
public struct FirebaseProject: Sendable, Hashable {
    /// The project ID, such as `my-app-1a2b3`.
    public let projectID: String
    /// The Web API key. API keys identify the project; they are not secret, and access is
    /// controlled by Security Rules and API key restrictions.
    public let apiKey: String
    /// The Firestore database, `(default)` unless the project has named databases.
    public let databaseID: String
    /// Sent as `X-Ios-Bundle-Identifier`, which an API key restricted to iOS apps requires.
    public let bundleID: String?
    /// The Authentication emulator, if requests should go there instead of Google.
    public private(set) var authEmulator: EmulatorHost?
    /// The Firestore emulator, if requests should go there instead of Google.
    public private(set) var firestoreEmulator: EmulatorHost?

    /// The name of the default Firestore database.
    public static let defaultDatabase = "(default)"

    /// Creates a project after checking the ID, key and database name.
    ///
    /// - Parameter bundleID: Defaults to the main bundle's identifier, which is what an
    ///   iOS-restricted API key expects. Pass `nil` from a server or command-line tool.
    public init(
        projectID: String,
        apiKey: String,
        databaseID: String = FirebaseProject.defaultDatabase,
        bundleID: String? = Bundle.main.bundleIdentifier
    ) throws {
        try Self.checkProjectID(projectID)
        try Self.checkAPIKey(apiKey)
        try Self.checkDatabaseID(databaseID)
        if let bundleID {
            guard !bundleID.isEmpty, bundleID.utf8Count <= 255,
                  bundleID.allSatisfy({ $0.isASCIILetterOrDigit || $0 == "." || $0 == "-" }) else {
                throw ValidationError("bundleID", "use letters, digits, '.' and '-' only")
            }
        }
        self.projectID = projectID
        self.apiKey = apiKey
        self.databaseID = databaseID
        self.bundleID = bundleID
    }

    /// Returns a copy that sends Authentication and Firestore requests to the emulators.
    ///
    /// Pass `nil` for a service that should keep using Google's servers.
    public func usingEmulators(auth: String?, firestore: String?) throws -> FirebaseProject {
        var copy = self
        copy.authEmulator = try auth.map(EmulatorHost.init)
        copy.firestoreEmulator = try firestore.map(EmulatorHost.init)
        return copy
    }

    /// Returns a copy that uses the emulators named in `FIREBASE_AUTH_EMULATOR_HOST` and
    /// `FIRESTORE_EMULATOR_HOST`, the variables `firebase emulators:exec` sets. Services without
    /// a variable keep their current setting.
    public func usingEmulatorsFromEnvironment(
        _ environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> FirebaseProject {
        var copy = self
        if let auth = environment["FIREBASE_AUTH_EMULATOR_HOST"], !auth.isEmpty {
            copy.authEmulator = try EmulatorHost(auth)
        }
        if let firestore = environment["FIRESTORE_EMULATOR_HOST"], !firestore.isEmpty {
            copy.firestoreEmulator = try EmulatorHost(firestore)
        }
        return copy
    }

    /// `projects/{projectID}/databases/{databaseID}`.
    var databaseName: String { "projects/\(projectID)/databases/\(databaseID)" }

    /// `projects/{projectID}/databases/{databaseID}/documents`.
    var documentsRoot: String { "\(databaseName)/documents" }

    // Project IDs are 6–30 characters: lowercase letters, digits and hyphens, starting with a
    // letter and not ending with a hyphen.
    static func checkProjectID(_ value: String) throws {
        let characters = Array(value)
        guard (6...30).contains(characters.count),
              characters.allSatisfy({ ($0.isASCIILetterOrDigit && !$0.isUppercase) || $0 == "-" }),
              characters.first?.isLetter == true, characters.last != "-" else {
            throw ValidationError(
                "projectID \"\(value)\"",
                "use 6–30 lowercase letters, digits and hyphens, starting with a letter"
            )
        }
    }

    private static func checkAPIKey(_ value: String) throws {
        guard !value.isEmpty, value.utf8Count <= 128,
              value.allSatisfy({ $0.isASCIILetterOrDigit || $0 == "-" || $0 == "_" }) else {
            throw ValidationError("apiKey", "use the Web API key from the Firebase console")
        }
    }

    // Database IDs are 4–63 characters: lowercase letters, digits and hyphens, starting with a
    // letter and ending with a letter or digit.
    private static func checkDatabaseID(_ value: String) throws {
        if value == defaultDatabase { return }
        let characters = Array(value)
        guard (4...63).contains(characters.count),
              characters.allSatisfy({ ($0.isASCIILetterOrDigit && !$0.isUppercase) || $0 == "-" }),
              characters.first?.isLetter == true, characters.last != "-" else {
            throw ValidationError("databaseID \"\(value)\"", "use 4–63 lowercase letters, digits and hyphens")
        }
    }
}
