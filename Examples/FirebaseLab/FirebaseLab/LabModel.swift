import Foundation
import iOSFirebaseTools
import Observation

/// Where FirebaseLab sends its requests.
enum LabConfiguration {
    /// The demo project the emulators run (`Emulators/firebase.json` at the repository root).
    static let emulatorProjectID = "demo-iosfirebasetools"

    /// A real project when the app bundles a GoogleService-Info.plist, the emulators otherwise.
    static func makeProject() throws -> (project: FirebaseProject, label: String) {
        if Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            let project = try GoogleServiceInfo.inMainBundle().project()
            return (project, "Project \(project.projectID)")
        }
        // The simulator shares the Mac's network, so 127.0.0.1 reaches the emulators.
        let host = ProcessInfo.processInfo.environment["EMULATOR_HOST"] ?? "127.0.0.1"
        let project = try FirebaseProject(projectID: emulatorProjectID, apiKey: "emulator-key")
            .usingEmulators(auth: "\(host):9099", firestore: "\(host):8080")
        return (project, "Local emulators at \(host)")
    }
}

@MainActor
@Observable
final class LabModel {
    private(set) var session: AuthSession?
    private(set) var notes: [FirestoreDocument<Note>] = []
    private(set) var claims: IDTokenClaims?
    private(set) var isWorking = false
    var message: String?
    let environmentLabel: String

    private let auth: FirebaseAuthClient
    private let firestore: FirestoreClient

    init() {
        do {
            let (project, label) = try LabConfiguration.makeProject()
            environmentLabel = label
            auth = FirebaseAuthClient(project: project, store: KeychainSessionStore(account: project.projectID))
            firestore = FirestoreClient(project: project, credentials: .user(auth))
        } catch {
            // The emulator project is a constant, so only a damaged plist ends up here.
            preconditionFailure("FirebaseLab configuration: \(error)")
        }
    }

    /// Restores the saved session, or signs out first when UI tests pass `-reset`.
    func start() async {
        if CommandLine.arguments.contains("-reset") {
            try? await auth.signOut()
        }
        await perform {
            self.session = try await self.auth.restoreSession()
            if self.session != nil { try await self.reload() }
        }
    }

    // MARK: - Account

    func signUp(email: String, password: String) async {
        await perform { try await self.didSignIn(self.auth.signUp(email: email, password: password)) }
    }

    func signIn(email: String, password: String) async {
        await perform { try await self.didSignIn(FirebaseLab.signIn(with: self.auth, email: email, password: password)) }
    }

    func continueAnonymously() async {
        await perform { try await self.didSignIn(self.auth.signInAnonymously()) }
    }

    func refreshToken() async {
        await perform {
            _ = try await self.auth.idToken(forceRefresh: true)
            self.session = await self.auth.session
            self.claims = try self.session?.unverifiedClaims()
        }
    }

    func signOut() async {
        await perform {
            try await self.auth.signOut()
            self.didSignOut()
        }
    }

    func deleteAccount() async {
        await perform {
            try await self.auth.deleteAccount()
            self.didSignOut()
        }
    }

    // MARK: - Notes

    func reload() async throws {
        guard let userID = session?.userID else { return }
        let loaded = try await loadNotes(ownerID: userID, from: firestore)
        notes = loaded.sorted { lhs, rhs in
            if lhs.data.pinned != rhs.data.pinned { return lhs.data.pinned }
            return (lhs.data.createdAt ?? .distantFuture) > (rhs.data.createdAt ?? .distantFuture)
        }
    }

    func refresh() async {
        await perform { try await self.reload() }
    }

    func add(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userID = session?.userID, !trimmed.isEmpty else { return }
        await perform {
            _ = try await addNote(trimmed, ownerID: userID, to: self.firestore)
            try await self.reload()
        }
    }

    func togglePin(_ note: FirestoreDocument<Note>) async {
        await perform {
            try await self.firestore.update(note.path.description, fields: ["pinned": .bool(!note.data.pinned)])
            try await self.reload()
        }
    }

    func delete(_ note: FirestoreDocument<Note>) async {
        await perform {
            try await deleteNote(at: note.path.description, in: self.firestore)
            try await self.reload()
        }
    }

    // MARK: - Helpers

    private func didSignIn(_ session: AuthSession) async throws {
        self.session = session
        claims = try session.unverifiedClaims()
        try await reload()
    }

    private func didSignOut() {
        session = nil
        claims = nil
        notes = []
    }

    private func perform(_ work: @escaping @MainActor () async throws -> Void) async {
        isWorking = true
        message = nil
        defer { isWorking = false }
        do {
            try await work()
        } catch {
            message = Self.describe(error)
        }
    }

    static func describe(_ error: any Error) -> String {
        switch error {
        case let error as AuthError:
            switch error.code {
            case .invalidLoginCredentials, .invalidPassword, .emailNotFound: "Wrong e-mail or password."
            case .emailExists: "An account with this e-mail already exists."
            case .weakPassword: "Use a password of at least 6 characters."
            case .invalidEmail: "Enter a valid e-mail address."
            case .tooManyAttempts: "Too many attempts. Try again later."
            default: error.message
            }
        case let error as ValidationError:
            error.description
        case let error as FirestoreError:
            "Firestore: \(error.message)"
        case let error as URLError where error.code == .cannotConnectToHost:
            "Cannot reach Firebase. Start the emulators with scripts/start-emulators.sh."
        default:
            error.localizedDescription
        }
    }
}
