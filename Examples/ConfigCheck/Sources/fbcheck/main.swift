import Foundation
import iOSFirebaseTools

let usage = """
Usage:
  fbcheck plist <GoogleService-Info.plist> [--bundle-id <app bundle ID>]
      Reports a plist for another app, a damaged API key or app ID, and a sender ID that does
      not match the project. Exits with 1 when it finds a problem, so it can stop a CI build.

  fbcheck token <ID token> --project <project ID> [--emulator]
      Verifies a Firebase ID token the way a server should and prints its claims. With
      --emulator it accepts the unsigned tokens of the Authentication emulator instead.
"""

/// The value after `--name`, if present.
func option(_ name: String, in arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: "--\(name)"), index + 1 < arguments.count else { return nil }
    return arguments[index + 1]
}

func checkPlist(_ arguments: [String]) throws -> Int32 {
    guard let path = arguments.first, !path.hasPrefix("--") else {
        print(usage)
        return 2
    }
    let info = try GoogleServiceInfo(contentsOf: URL(fileURLWithPath: path))
    let problems = info.problems(bundleIdentifier: option("bundle-id", in: arguments))
    print("Project \(info.projectID), app \(info.googleAppID), bundle \(info.bundleID)")
    guard !problems.isEmpty else {
        print("No problems found.")
        return 0
    }
    for problem in problems {
        print("error: \(problem)")
    }
    return 1
}

func verifyToken(_ arguments: [String]) async throws -> Int32 {
    guard let token = arguments.first, !token.hasPrefix("--"), let projectID = option("project", in: arguments) else {
        print(usage)
        return 2
    }
    let verifier = arguments.contains("--emulator")
        ? try IDTokenVerifier.emulator(projectID: projectID)
        : try IDTokenVerifier(projectID: projectID)
    do {
        let claims = try await verifier.verify(token)
        print("Valid token for user \(claims.subject)")
        print("  e-mail:      \(claims.email ?? "none") (verified: \(claims.emailVerified))")
        print("  provider:    \(claims.signInProvider ?? "unknown")")
        print("  signed in:   \(claims.authenticatedAt.formatted(.iso8601))")
        print("  expires:     \(claims.expiresAt.formatted(.iso8601))")
        return 0
    } catch let error as TokenError {
        print("error: \(error)")
        return 1
    }
}

let arguments = Array(CommandLine.arguments.dropFirst())
let status: Int32
do {
    switch arguments.first {
    case "plist": status = try checkPlist(Array(arguments.dropFirst()))
    case "token": status = try await verifyToken(Array(arguments.dropFirst()))
    default:
        print(usage)
        status = 2
    }
} catch {
    print("error: \(error)")
    status = 1
}
exit(status)
