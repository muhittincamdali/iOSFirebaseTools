import Foundation
import Testing
@testable import iOSFirebaseTools

enum Emulators {
    static var areRunning: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["FIREBASE_AUTH_EMULATOR_HOST"] != nil && environment["FIRESTORE_EMULATOR_HOST"] != nil
    }
}

/// End-to-end tests against the Firebase Local Emulator Suite with the rules in
/// `Emulators/firestore.rules`. They run when `firebase emulators:exec` sets the emulator
/// variables, and are skipped otherwise:
///
/// ```sh
/// firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools \
///   'swift test --filter Emulator'
/// ```
@Suite("Emulator end to end", .enabled(if: Emulators.areRunning), .serialized)
struct EmulatorTests {
    struct TrackedNote: Codable, Equatable, Sendable {
        var text: String
        var ownerID: String
        var views: Int = 0
        var createdAt: Date?
    }

    let project: FirebaseProject

    init() throws {
        project = try FirebaseProject(projectID: "demo-iosfirebasetools", apiKey: "emulator-key", bundleID: nil)
            .usingEmulatorsFromEnvironment()
    }

    func newUser() async throws -> (FirebaseAuthClient, FirestoreClient, AuthSession) {
        let auth = FirebaseAuthClient(project: project, store: InMemorySessionStore())
        let session = try await auth.signUp(email: "user-\(UUID().uuidString.prefix(8))@example.com", password: "correct horse")
        return (auth, FirestoreClient(project: project, credentials: .user(auth)), session)
    }

    @Test("Accounts: sign up, sign in, wrong password, duplicate e-mail, refresh and delete")
    func accounts() async throws {
        let email = "ada-\(UUID().uuidString.prefix(8))@example.com".lowercased()
        let auth = FirebaseAuthClient(project: project, store: InMemorySessionStore())
        let created = try await auth.signUp(email: email, password: "correct horse")
        #expect(created.email == email)

        let again = await #expect(throws: AuthError.self) { try await auth.signUp(email: email, password: "correct horse") }
        #expect(again?.code == .emailExists)

        let wrong = await #expect(throws: AuthError.self) { try await auth.signIn(email: email, password: "wrong password") }
        #expect([.invalidLoginCredentials, .invalidPassword].contains(wrong?.code))

        let session = try await auth.signIn(email: email, password: "correct horse")
        #expect(session.userID == created.userID)
        let refreshed = try await auth.idToken(forceRefresh: true)
        #expect(await auth.session?.idToken == refreshed)
        #expect(await auth.session?.userID == created.userID)

        let claims = try await IDTokenVerifier.emulator(projectID: project.projectID).verify(refreshed.revealed)
        #expect(claims.subject == created.userID)
        #expect(claims.email == email)
        #expect(claims.signInProvider == "password")

        try await auth.deleteAccount()
        let gone = await #expect(throws: AuthError.self) { try await auth.signIn(email: email, password: "correct horse") }
        #expect([.invalidLoginCredentials, .emailNotFound].contains(gone?.code))
    }

    @Test("Anonymous users get a session the verifier accepts")
    func anonymous() async throws {
        let auth = FirebaseAuthClient(project: project, store: InMemorySessionStore())
        let session = try await auth.signInAnonymously()
        #expect(session.isAnonymous)
        let claims = try await IDTokenVerifier.emulator(projectID: project.projectID).verify(session.idToken.revealed)
        #expect(claims.signInProvider == "anonymous")
    }

    @Test("Sign in with Apple creates a user with the apple.com provider")
    func appleSignIn() async throws {
        let auth = FirebaseAuthClient(project: project, store: InMemorySessionStore())
        let nonce = AppleSignInNonce()
        let now = Date().timeIntervalSince1970.rounded(.down)
        let appleUser = "apple-\(UUID().uuidString.prefix(8).lowercased())"
        // The emulator accepts unsigned provider tokens; Apple's real ones are checked by Firebase.
        let idToken = Fixtures.unsignedToken([
            "iss": "https://appleid.apple.com", "aud": "io.github.muhittincamdali.FirebaseLab", "sub": appleUser,
            "email": "\(appleUser)@privaterelay.appleid.com", "nonce": nonce.sha256, "iat": now, "exp": now + 600,
        ])
        let session = try await auth.signIn(with: .apple(idToken: idToken, rawNonce: nonce.raw))
        #expect(session.email == "\(appleUser)@privaterelay.appleid.com")
        let claims = try await IDTokenVerifier.emulator(projectID: project.projectID).verify(session.idToken.revealed)
        #expect(claims.signInProvider == "apple.com")
        #expect(try await auth.signIn(with: .apple(idToken: idToken, rawNonce: nonce.raw)).userID == session.userID)
    }

    @Test("Notes: create, read, query, update with transforms and delete under Security Rules")
    func notesLifecycle() async throws {
        let (_, firestore, session) = try await newUser()
        let path = try await firestore.add(TrackedNote(text: "Buy milk", ownerID: session.userID), to: "notes",
                                           transforms: ["createdAt": .serverTimestamp])
        let stored = try #require(try await firestore.document(path, as: TrackedNote.self))
        #expect(stored.data.text == "Buy milk")
        let createdAt = try #require(stored.data.createdAt)
        #expect(abs(createdAt.timeIntervalSinceNow) < 120)

        try await firestore.update(path, fields: ["text": "Buy oat milk"], transforms: ["views": .increment(2)])
        try await firestore.update(path, fields: [:], transforms: ["views": .increment(1)])
        let updated = try #require(try await firestore.document(path, as: TrackedNote.self))
        #expect(updated.data.text == "Buy oat milk")
        #expect(updated.data.views == 3)

        let mine = FirestoreQuery(collection: "notes").filter("ownerID", .equal, session.userID)
        #expect(try await firestore.documents(matching: mine, as: TrackedNote.self).map(\.path.description) == [path])

        try await firestore.delete(path)
        #expect(try await firestore.document(path, as: TrackedNote.self) == nil)
    }

    @Test("Another user's notes are denied, and so is a request without a token")
    func rulesSeeTheToken() async throws {
        let (_, owner, ownerSession) = try await newUser()
        let (_, other, _) = try await newUser()
        let path = try await owner.add(TrackedNote(text: "Private", ownerID: ownerSession.userID), to: "notes")

        let read = await #expect(throws: FirestoreError.self) { try await other.document(path, as: TrackedNote.self) }
        #expect(read?.code == .permissionDenied)
        let query = FirestoreQuery(collection: "notes").filter("ownerID", .equal, ownerSession.userID)
        let listed = await #expect(throws: FirestoreError.self) { try await other.documents(matching: query, as: TrackedNote.self) }
        #expect(listed?.code == .permissionDenied)
        let anonymous = FirestoreClient(project: project)
        let denied = await #expect(throws: FirestoreError.self) { try await anonymous.document(path, as: TrackedNote.self) }
        #expect(denied?.code == .permissionDenied)
        let forged = await #expect(throws: FirestoreError.self) {
            try await other.add(TrackedNote(text: "Spoofed", ownerID: ownerSession.userID), to: "notes")
        }
        #expect(forged?.code == .permissionDenied)
    }

    @Test("Batches are atomic and creates do not overwrite")
    func batches() async throws {
        let (_, firestore, _) = try await newUser()
        let base = "scratch/\(UUID().uuidString)/items"
        try await firestore.set(["n": 1], at: "\(base)/a")

        var batch = WriteBatch()
        try batch.create(["n": 2], at: "\(base)/b")
        try batch.create(["n": 3], at: "\(base)/a")
        let error = await #expect(throws: FirestoreError.self) { try await firestore.commit(batch) }
        #expect(error?.code == .alreadyExists)
        #expect(try await firestore.document("\(base)/b", as: [String: Int].self) == nil)

        try await firestore.set(["m": 5], at: "\(base)/a", merge: true)
        #expect(try await firestore.document("\(base)/a", as: [String: Int].self)?.data == ["n": 1, "m": 5])
        let missing = await #expect(throws: FirestoreError.self) { try await firestore.update("\(base)/zzz", fields: ["n": 1]) }
        #expect(missing?.code == .notFound)
    }

    struct Everything: Codable, Equatable, Sendable {
        var integer: Int64
        var double: Double
        var date: Date
        var data: Data
        var point: GeoPoint
        var nested: [String: [Int]]
        var optional: String?
        var weird: [String: Bool]
    }

    @Test("Every value type, odd IDs and odd field names survive a round trip")
    func roundTrips() async throws {
        let (_, firestore, _) = try await newUser()
        let value = Everything(
            integer: .min, double: -0.5, date: Date(timeIntervalSince1970: 1_800_000_000.123456), data: Data([0, 255, 128]),
            point: try GeoPoint(latitude: -33.86, longitude: 151.21), nested: ["a": [1, 2, 3]], optional: nil,
            weird: ["first name": true, "a.b": false, "back`tick": true, "1st": true]
        )
        let path = "scratch/\(UUID().uuidString)/odd/a b?c#d:e%2Ff;g"
        try await firestore.set(value, at: path)
        let stored = try #require(try await firestore.document(path, as: Everything.self))
        #expect(stored.id == "a b?c#d:e%2Ff;g")
        #expect(stored.data == value)

        try await firestore.update(path, fields: [try FieldPath(["weird", "a.b"]): true])
        #expect(try await firestore.document(path, as: Everything.self)?.data.weird["a.b"] == true)

        try await firestore.set(["nan": FirestoreValue.double(.nan)], at: "\(path)/x/nan")
        let nan = try await firestore.document("\(path)/x/nan", as: [String: Double].self)
        #expect(nan?.data["nan"]?.isNaN == true)
    }

    @Test("Listing pages through a collection")
    func listsPages() async throws {
        let owner = FirestoreClient(project: project, credentials: .emulatorOwner)
        let base = "scratch/\(UUID().uuidString)/items"
        var batch = WriteBatch()
        for index in 0..<5 { try batch.set(["index": index], at: "\(base)/item-\(index)") }
        try await owner.commit(batch)

        var seen: [String] = []
        var token: String?
        repeat {
            let page = try await owner.documents(in: base, as: [String: Int].self, pageSize: 2, pageToken: token)
            seen += page.documents.map(\.id)
            token = page.nextPageToken
        } while token != nil
        #expect(seen == (0..<5).map { "item-\($0)" })
    }
}
