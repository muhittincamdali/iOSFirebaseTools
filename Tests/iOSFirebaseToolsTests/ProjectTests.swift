import Foundation
import Testing
@testable import iOSFirebaseTools

@Suite("Projects and emulator addresses")
struct ProjectTests {
    @Test("Valid project IDs are accepted", arguments: ["demo-notes", "my-app-1a2b3", "abcdef", String(repeating: "a", count: 30)])
    func acceptsProjectIDs(_ id: String) throws {
        #expect(try FirebaseProject(projectID: id, apiKey: "key", bundleID: nil).projectID == id)
    }

    @Test("Invalid project IDs are rejected", arguments: [
        "", "abc", "Demo-notes", "1demo-notes", "demo-notes-", "demo_notes", "demo/notes", "demo-notes?x=1",
        String(repeating: "a", count: 31), "démo-notes", "demo notes",
    ])
    func rejectsProjectIDs(_ id: String) {
        #expect(throws: ValidationError.self) { try FirebaseProject(projectID: id, apiKey: "key", bundleID: nil) }
    }

    @Test("API keys, database IDs and bundle IDs are checked")
    func checksOtherFields() throws {
        #expect(throws: ValidationError.self) { try FirebaseProject(projectID: "demo-notes", apiKey: "", bundleID: nil) }
        #expect(throws: ValidationError.self) { try FirebaseProject(projectID: "demo-notes", apiKey: "key&x=1", bundleID: nil) }
        #expect(throws: ValidationError.self) { try FirebaseProject(projectID: "demo-notes", apiKey: "k", databaseID: "Default", bundleID: nil) }
        #expect(throws: ValidationError.self) { try FirebaseProject(projectID: "demo-notes", apiKey: "k", bundleID: "com.example\nx") }
        let named = try FirebaseProject(projectID: "demo-notes", apiKey: "k", databaseID: "eu-db", bundleID: "com.example.app")
        #expect(named.documentsRoot == "projects/demo-notes/databases/eu-db/documents")
    }

    @Test("Emulator addresses parse host and port", arguments: [
        ("127.0.0.1:9099", "127.0.0.1", 9099), ("localhost:8080", "localhost", 8080),
        ("[::1]:9099", "::1", 9099), ("[fe80::1]:8080", "fe80::1", 8080), ("firebase-emulator.internal:1", "firebase-emulator.internal", 1),
    ])
    func parsesEmulatorHosts(_ text: String, _ host: String, _ port: Int) throws {
        let parsed = try EmulatorHost(text)
        #expect(parsed.host == host)
        #expect(parsed.port == port)
        #expect(parsed.description == text)
    }

    @Test("Emulator addresses that could redirect requests or overflow are rejected", arguments: [
        "", "localhost", "localhost:", ":8080", "http://localhost:8080", "localhost:8080/v1", "localhost:0",
        "localhost:65536", "localhost:99999999999999999999999", "localhost:-1", "localhost:+80", "local host:80",
        "evil.com#@localhost:80", "user@localhost:80", "[::1:80", "[zz::1]:80", "[::::::]:80", "[1:2]:80", "[:]:80",
        "[fe80::1%en0]:80", "localhost:٨٠", "-bad.com:80",
    ])
    func rejectsEmulatorHosts(_ text: String) {
        #expect(throws: ValidationError.self) { try EmulatorHost(text) }
    }

    @Test("Emulators come from the variables firebase emulators:exec sets")
    func readsEmulatorEnvironment() throws {
        let project = try Fixtures.project().usingEmulatorsFromEnvironment([
            "FIREBASE_AUTH_EMULATOR_HOST": "127.0.0.1:9099",
            "FIRESTORE_EMULATOR_HOST": "",
        ])
        #expect(project.authEmulator?.port == 9099)
        #expect(project.firestoreEmulator == nil)
        #expect(throws: ValidationError.self) {
            try Fixtures.project().usingEmulatorsFromEnvironment(["FIRESTORE_EMULATOR_HOST": "https://evil.example:443"])
        }
    }
}

@Suite("GoogleService-Info.plist")
struct GoogleServiceInfoTests {
    // Built at runtime so the source holds no string shaped like a real Google API key.
    static let fakeKey = "AIza" + String(repeating: "x", count: 35)

    static func plist(bundleID: String = "com.example.notes", apiKey: String = GoogleServiceInfoTests.fakeKey,
                      appID: String = "1:123456789012:ios:0a1b2c3d4e5f6a7b", sender: String = "123456789012") -> Data {
        Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>API_KEY</key><string>\(apiKey)</string>
        <key>GCM_SENDER_ID</key><string>\(sender)</string>
        <key>PLIST_VERSION</key><string>1</string>
        <key>BUNDLE_ID</key><string>\(bundleID)</string>
        <key>PROJECT_ID</key><string>notes-prod-4f2a</string>
        <key>STORAGE_BUCKET</key><string>notes-prod-4f2a.firebasestorage.app</string>
        <key>IS_GCM_ENABLED</key><true/>
        <key>GOOGLE_APP_ID</key><string>\(appID)</string>
        </dict></plist>
        """.utf8)
    }

    @Test("A file from the console reads and has no problems")
    func readsConsoleFile() throws {
        let info = try GoogleServiceInfo(data: Self.plist())
        #expect(info.projectID == "notes-prod-4f2a")
        #expect(info.storageBucket == "notes-prod-4f2a.firebasestorage.app")
        #expect(info.databaseURL == nil)
        #expect(info.problems(bundleIdentifier: "com.example.notes").isEmpty)
        let project = try info.project()
        #expect(project.bundleID == "com.example.notes")
        #expect(project.apiKey == info.apiKey)
    }

    @Test("A plist for another app or a damaged key is reported")
    func reportsProblems() throws {
        let info = try GoogleServiceInfo(data: Self.plist(apiKey: "not-a-key", appID: "1:999:ios:abc", sender: "123"))
        let problems = info.problems(bundleIdentifier: "com.example.notes.dev")
        #expect(problems.contains(.bundleIDMismatch(file: "com.example.notes", app: "com.example.notes.dev")))
        #expect(problems.contains(.malformedAPIKey))
        #expect(problems.contains(.senderIDMismatch(senderID: "123", appID: "1:999:ios:abc")))
        #expect(problems.count == 3)
    }

    @Test("Malformed app IDs are reported", arguments: ["", "1:123:android:abc", "2:123:ios:abc", "1::ios:abc", "1:123:ios:xyz", "1:123:ios:ab:cd"])
    func reportsMalformedAppIDs(_ appID: String) throws {
        let info = try GoogleServiceInfo(data: Self.plist(appID: appID))
        #expect(info.problems(bundleIdentifier: nil) == [.malformedAppID(appID)])
    }

    @Test("A missing key or an oversized file is an error, not a crash")
    func rejectsBadFiles() throws {
        #expect(throws: (any Error).self) { try GoogleServiceInfo(data: Data("<plist><dict/></plist>".utf8)) }
        #expect(throws: (any Error).self) { try GoogleServiceInfo(data: Data("not a plist".utf8)) }
        #expect(throws: ValidationError.self) { try GoogleServiceInfo(data: Data(count: 70_000)) }
        #expect(throws: ValidationError.self) { try GoogleServiceInfo.inMainBundle(Bundle(for: BundleMarker.self)) }
    }

    @Test("A file on disk is read with the size cap")
    func readsFileFromDisk() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GoogleService-Info-\(UUID().uuidString).plist")
        try Self.plist().write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(try GoogleServiceInfo(contentsOf: url).bundleID == "com.example.notes")
        try Data(count: 200_000).write(to: url)
        #expect(throws: ValidationError.self) { try GoogleServiceInfo(contentsOf: url) }
    }
}

private final class BundleMarker {}
