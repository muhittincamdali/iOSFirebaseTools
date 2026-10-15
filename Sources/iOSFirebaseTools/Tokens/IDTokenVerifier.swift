import Foundation

/// Verifies Firebase ID tokens on a server, following Firebase's rules for third-party JWT
/// libraries: an `RS256` signature by one of Google's published keys, `aud` equal to the project
/// ID, `iss` equal to `https://securetoken.google.com/<project ID>`, a non-empty `sub`, `exp`
/// in the future and `iat` and `auth_time` in the past.
///
/// ```swift
/// let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3")
/// let claims = try await verifier.verify(bearerToken) // throws TokenError
/// print(claims.subject) // the user's ID
/// ```
///
/// Keys are fetched from Google when first needed and kept for as long as the response's
/// `Cache-Control: max-age` allows. A token with an unknown key ID triggers at most one fetch a
/// minute, so forged tokens cannot make the server flood Google with requests. If Google cannot
/// be reached when the keys expire, the keys already fetched keep working until the next fetch
/// succeeds.
public actor IDTokenVerifier {
    /// Google's JSON Web Key Set for Firebase ID tokens.
    public static let googleKeysURL = URL(string: "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com")!

    private enum KeySource {
        case google(any HTTPTransport)
        case fixed([String: RSAPublicKey])
        case unsignedEmulatorTokens
    }

    public nonisolated let projectID: String
    private let source: KeySource
    private let clockSkew: TimeInterval
    private let clock: @Sendable () -> Date
    private var cachedKeys: [String: RSAPublicKey] = [:]
    private var cacheExpiry: Date = .distantPast
    private var lastFetch: Date?
    private var fetchTask: Task<Void, any Error>?

    private static let maxClockSkew: TimeInterval = 300
    private static let minRefetchInterval: TimeInterval = 60

    /// A verifier that fetches Google's public keys.
    ///
    /// - Parameter clockSkew: Seconds of difference allowed between this server's clock and
    ///   Google's, from 0 to 300. Defaults to 60.
    public init(
        projectID: String,
        transport: any HTTPTransport = URLSessionTransport(),
        clockSkew: TimeInterval = 60,
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        try self.init(projectID: projectID, source: .google(transport), clockSkew: clockSkew, clock: clock)
    }

    /// A verifier with fixed keys, by key ID. Use it in tests, or to pin keys you fetched yourself.
    public init(
        projectID: String,
        keys: [String: RSAPublicKey],
        clockSkew: TimeInterval = 60,
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        try self.init(projectID: projectID, source: .fixed(keys), clockSkew: clockSkew, clock: clock)
    }

    /// A verifier for tokens from the Authentication emulator, which are not signed
    /// (`alg: none`). It checks every claim but no signature, and it rejects signed tokens, so
    /// it cannot be used against production tokens by mistake. Never use it in production.
    public static func emulator(projectID: String, clock: @escaping @Sendable () -> Date = Date.init) throws -> IDTokenVerifier {
        try IDTokenVerifier(projectID: projectID, source: .unsignedEmulatorTokens, clockSkew: 60, clock: clock)
    }

    private init(projectID: String, source: KeySource, clockSkew: TimeInterval, clock: @escaping @Sendable () -> Date) throws {
        try FirebaseProject.checkProjectID(projectID)
        self.projectID = projectID
        self.source = source
        // NaN or infinity would turn every comparison below false; treat them as no skew.
        self.clockSkew = clockSkew.isFinite ? min(max(clockSkew, 0), Self.maxClockSkew) : 0
        self.clock = clock
    }

    /// Returns the token's claims when the token is valid, and throws ``TokenError`` otherwise.
    public func verify(_ token: String) async throws -> IDTokenClaims {
        let jwt = try JSONWebToken(token)
        try await checkSignature(of: jwt)
        let claims = try jwt.claims()
        try check(claims, now: clock())
        return claims
    }

    private func checkSignature(of jwt: JSONWebToken) async throws {
        if case .unsignedEmulatorTokens = source {
            guard jwt.header.alg == "none" else { throw TokenError.unsupportedAlgorithm(Self.short(jwt.header.alg)) }
            return
        }
        guard jwt.header.alg == "RS256" else { throw TokenError.unsupportedAlgorithm(Self.short(jwt.header.alg)) }
        guard let kid = jwt.header.kid, !kid.isEmpty else { throw TokenError.unknownKey(nil) }
        guard let key = try await key(for: kid) else { throw TokenError.unknownKey(Self.short(kid)) }
        guard key.isValidSignature(jwt.signature, for: jwt.signingInput) else { throw TokenError.invalidSignature }
    }

    private func check(_ claims: IDTokenClaims, now: Date) throws {
        guard claims.audience == projectID else { throw TokenError.wrongAudience(Self.short(claims.audience)) }
        guard claims.issuer == "https://securetoken.google.com/\(projectID)" else {
            throw TokenError.wrongIssuer(Self.short(claims.issuer))
        }
        guard !claims.subject.isEmpty, claims.subject.utf8Count <= 128 else { throw TokenError.emptySubject }
        guard claims.expiresAt.addingTimeInterval(clockSkew) > now else { throw TokenError.expired(claims.expiresAt) }
        guard claims.issuedAt.addingTimeInterval(-clockSkew) <= now,
              claims.authenticatedAt.addingTimeInterval(-clockSkew) <= now else {
            throw TokenError.notYetValid
        }
    }

    private func key(for kid: String) async throws -> RSAPublicKey? {
        switch source {
        case let .fixed(keys):
            return keys[kid]
        case .unsignedEmulatorTokens:
            return nil
        case let .google(transport):
            let now = clock()
            let stale = now >= cacheExpiry
            let unknown = cachedKeys[kid] == nil
            // At most one fetch a minute, whether keys expired, a kid is unknown or Google failed.
            let mayRefetch = lastFetch.map { now.timeIntervalSince($0) >= Self.minRefetchInterval } ?? true
            // A fetch already running is awaited: its keys may be the ones this token needs.
            if fetchTask != nil || ((stale || unknown) && mayRefetch) {
                do {
                    try await refreshKeys(using: transport)
                } catch {
                    // Keys that were valid a moment ago still verify while Google is unreachable.
                    if cachedKeys[kid] == nil { throw error }
                }
            }
            return cachedKeys[kid]
        }
    }

    // Concurrent verifications share one fetch.
    private func refreshKeys(using transport: any HTTPTransport) async throws {
        if let fetchTask { return try await fetchTask.value }
        let task = Task { try await self.fetchKeys(using: transport) }
        fetchTask = task
        defer { fetchTask = nil }
        try await task.value
    }

    private func fetchKeys(using transport: any HTTPTransport) async throws {
        let now = clock()
        lastFetch = now
        let response: HTTPResponse
        do {
            response = try await transport.send(HTTPRequest(method: "GET", url: Self.googleKeysURL))
        } catch {
            throw TokenError.keysUnavailable(String(describing: error))
        }
        guard response.statusCode == 200 else { throw TokenError.keysUnavailable("HTTP \(response.statusCode)") }
        cachedKeys = try KeySet.parse(response.body)
        cacheExpiry = now.addingTimeInterval(KeySet.maxAge(cacheControl: response.headers["cache-control"]))
    }

    private static func short(_ value: String) -> String {
        value.count > 64 ? "\(value.prefix(64))…" : value
    }
}

/// Reads a JSON Web Key Set and its cache lifetime.
enum KeySet {
    private struct Body: Decodable {
        struct Key: Decodable {
            let kid: String?
            let kty: String?
            let alg: String?
            let n: String?
            let e: String?
        }

        let keys: [Key]
    }

    static let maxKeys = 32
    static let defaultMaxAge: TimeInterval = 3_600
    static let longestMaxAge: TimeInterval = 86_400

    static func parse(_ data: Data) throws -> [String: RSAPublicKey] {
        guard let body = try? JSONDecoder().decode(Body.self, from: data) else {
            throw TokenError.keysUnavailable("the key set is not JSON Web Keys")
        }
        guard body.keys.count <= maxKeys else { throw TokenError.keysUnavailable("too many keys") }
        var keys: [String: RSAPublicKey] = [:]
        for key in body.keys where key.kty == "RSA" && (key.alg == nil || key.alg == "RS256") {
            guard let kid = key.kid, let n = key.n, let e = key.e else { continue }
            keys[kid] = try RSAPublicKey(modulus: n, exponent: e)
        }
        guard !keys.isEmpty else { throw TokenError.keysUnavailable("the key set has no RS256 keys") }
        return keys
    }

    /// `max-age` from a `Cache-Control` header, limited to one day.
    static func maxAge(cacheControl: String?) -> TimeInterval {
        guard let cacheControl else { return defaultMaxAge }
        for directive in cacheControl.split(separator: ",") {
            let parts = directive.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2, parts[0].lowercased() == "max-age" else { continue }
            // Digits only, and few enough that the conversion cannot overflow.
            guard (1...9).contains(parts[1].count), parts[1].allSatisfy(\.isASCIIDigit),
                  let seconds = Int(parts[1]) else { return defaultMaxAge }
            return min(TimeInterval(seconds), longestMaxAge)
        }
        return defaultMaxAge
    }
}
