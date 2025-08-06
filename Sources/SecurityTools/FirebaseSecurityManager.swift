import Foundation
import FirebaseAppCheck
import CryptoKit

/// Firebase Security Manager for handling app security, certificate pinning, and security validation
public class FirebaseSecurityManager {
    
    // MARK: - Singleton
    public static let shared = FirebaseSecurityManager()
    private init() {}
    
    // MARK: - Properties
    private var appCheck: AppCheck?
    private var isConfigured = false
    
    // MARK: - Configuration
    public struct SecurityConfiguration {
        public var enableAppCheck: Bool = true
        public var enableCertificatePinning: Bool = true
        public var enableNetworkSecurity: Bool = true
        public var enableDataEncryption: Bool = true
        public var enableSecureStorage: Bool = true
        public var enableBiometricAuth: Bool = false
        public var enableJailbreakDetection: Bool = true
        public var enableDebuggerDetection: Bool = true
        
        public init() {}
    }
    
    // MARK: - Error Types
    public enum SecurityError: Error, LocalizedError {
        case appCheckFailed(Error)
        case certificatePinningFailed
        case networkSecurityFailed
        case dataEncryptionFailed
        case secureStorageFailed
        case biometricAuthFailed
        case jailbreakDetected
        case debuggerDetected
        case notConfigured
        case invalidConfiguration
        
        public var errorDescription: String? {
            switch self {
            case .appCheckFailed(let error):
                return "App Check failed: \(error.localizedDescription)"
            case .certificatePinningFailed:
                return "Certificate pinning validation failed"
            case .networkSecurityFailed:
                return "Network security validation failed"
            case .dataEncryptionFailed:
                return "Data encryption failed"
            case .secureStorageFailed:
                return "Secure storage operation failed"
            case .biometricAuthFailed:
                return "Biometric authentication failed"
            case .jailbreakDetected:
                return "Jailbreak detected on device"
            case .debuggerDetected:
                return "Debugger detected on device"
            case .notConfigured:
                return "Security manager not configured"
            case .invalidConfiguration:
                return "Invalid security configuration"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Configure the security manager
    /// - Parameters:
    ///   - config: Security configuration
    ///   - completion: Completion handler
    public func configure(_ config: SecurityConfiguration, completion: @escaping (Result<Void, SecurityError>) -> Void) {
        guard !isConfigured else {
            completion(.failure(.invalidConfiguration))
            return
        }
        
        // Configure App Check
        if config.enableAppCheck {
            configureAppCheck { result in
                switch result {
                case .success:
                    print("✅ App Check configured")
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
        
        // Configure certificate pinning
        if config.enableCertificatePinning {
            configureCertificatePinning()
        }
        
        // Configure network security
        if config.enableNetworkSecurity {
            configureNetworkSecurity()
        }
        
        // Configure secure storage
        if config.enableSecureStorage {
            configureSecureStorage()
        }
        
        isConfigured = true
        completion(.success(()))
    }
    
    /// Validate app security
    /// - Parameter completion: Completion handler
    public func validateSecurity(completion: @escaping (Result<Bool, SecurityError>) -> Void) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        var securityChecks: [Result<Bool, SecurityError>] = []
        let group = DispatchGroup()
        
        // Check for jailbreak
        group.enter()
        checkJailbreak { result in
            securityChecks.append(result)
            group.leave()
        }
        
        // Check for debugger
        group.enter()
        checkDebugger { result in
            securityChecks.append(result)
            group.leave()
        }
        
        // Validate App Check
        group.enter()
        validateAppCheck { result in
            securityChecks.append(result)
            group.leave()
        }
        
        group.notify(queue: .main) {
            let failures = securityChecks.compactMap { result -> SecurityError? in
                if case .failure(let error) = result {
                    return error
                }
                return nil
            }
            
            if failures.isEmpty {
                completion(.success(true))
            } else {
                completion(.failure(failures.first!))
            }
        }
    }
    
    /// Encrypt sensitive data
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - completion: Completion handler
    public func encryptData(
        _ data: Data,
        key: String,
        completion: @escaping (Result<Data, SecurityError>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        do {
            let keyData = key.data(using: .utf8)!
            let hashedKey = SHA256.hash(data: keyData)
            let symmetricKey = SymmetricKey(data: hashedKey)
            
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            let encryptedData = sealedBox.combined
            
            completion(.success(encryptedData!))
        } catch {
            completion(.failure(.dataEncryptionFailed))
        }
    }
    
    /// Decrypt sensitive data
    /// - Parameters:
    ///   - data: Encrypted data
    ///   - key: Decryption key
    ///   - completion: Completion handler
    public func decryptData(
        _ data: Data,
        key: String,
        completion: @escaping (Result<Data, SecurityError>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        do {
            let keyData = key.data(using: .utf8)!
            let hashedKey = SHA256.hash(data: keyData)
            let symmetricKey = SymmetricKey(data: hashedKey)
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            completion(.success(decryptedData))
        } catch {
            completion(.failure(.dataEncryptionFailed))
        }
    }
    
    /// Store data securely
    /// - Parameters:
    ///   - data: Data to store
    ///   - key: Storage key
    ///   - completion: Completion handler
    public func storeSecureData(
        _ data: Data,
        key: String,
        completion: @escaping (Result<Void, SecurityError>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        encryptData(data, key: key) { result in
            switch result {
            case .success(let encryptedData):
                // Store encrypted data in Keychain
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: key,
                    kSecValueData as String: encryptedData,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                ]
                
                let status = SecItemAdd(query as CFDictionary, nil)
                
                if status == errSecSuccess {
                    completion(.success(()))
                } else {
                    completion(.failure(.secureStorageFailed))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Retrieve secure data
    /// - Parameters:
    ///   - key: Storage key
    ///   - decryptionKey: Decryption key
    ///   - completion: Completion handler
    public func retrieveSecureData(
        key: String,
        decryptionKey: String,
        completion: @escaping (Result<Data, SecurityError>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(.notConfigured))
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let encryptedData = result as? Data {
            decryptData(encryptedData, key: decryptionKey, completion: completion)
        } else {
            completion(.failure(.secureStorageFailed))
        }
    }
    
    /// Validate certificate pinning
    /// - Parameter completion: Completion handler
    public func validateCertificatePinning(completion: @escaping (Result<Bool, SecurityError>) -> Void) {
        // Implement certificate pinning validation
        // This is a simplified example
        let expectedCertificates = [
            "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
        ]
        
        // In a real implementation, you would validate against actual certificates
        completion(.success(true))
    }
    
    /// Check for jailbreak
    /// - Parameter completion: Completion handler
    public func checkJailbreak(completion: @escaping (Result<Bool, SecurityError>) -> Void) {
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                completion(.failure(.jailbreakDetected))
                return
            }
        }
        
        // Additional checks
        let suspiciousApps = [
            "Cydia",
            "Sileo",
            "Zebra",
            "Installer"
        ]
        
        for app in suspiciousApps {
            if let url = URL(string: "cydia://package/\(app)"),
               UIApplication.shared.canOpenURL(url) {
                completion(.failure(.jailbreakDetected))
                return
            }
        }
        
        completion(.success(true))
    }
    
    /// Check for debugger
    /// - Parameter completion: Completion handler
    public func checkDebugger(completion: @escaping (Result<Bool, SecurityError>) -> Void) {
        #if DEBUG
        // In debug builds, allow debugger
        completion(.success(true))
        #else
        // In release builds, check for debugger
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.size
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        
        if (info.kp_proc.p_flag & P_TRACED) != 0 {
            completion(.failure(.debuggerDetected))
        } else {
            completion(.success(true))
        }
        #endif
    }
    
    /// Generate secure random data
    /// - Parameter length: Length of random data
    /// - Returns: Random data
    public func generateSecureRandomData(length: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return Data(bytes)
    }
    
    /// Hash data securely
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    public func hashData(_ data: Data) -> Data {
        let hashed = SHA256.hash(data: data)
        return Data(hashed)
    }
    
    /// Generate secure token
    /// - Returns: Secure token
    public func generateSecureToken() -> String {
        let randomData = generateSecureRandomData(length: 32)
        return randomData.base64EncodedString()
    }
    
    // MARK: - Private Methods
    
    private func configureAppCheck(completion: @escaping (Result<Void, SecurityError>) -> Void) {
        #if DEBUG
        // Use debug provider for development
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        // Use device check provider for production
        let providerFactory = AppAttestProvider.factory()
        #endif
        
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        appCheck = AppCheck.appCheck()
        appCheck?.token(forcingRefresh: false) { token, error in
            if let error = error {
                completion(.failure(.appCheckFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func configureCertificatePinning() {
        // Configure certificate pinning
        // This would typically involve setting up URLSession delegate
        // and validating certificates against pinned certificates
    }
    
    private func configureNetworkSecurity() {
        // Configure network security settings
        // This could include TLS configuration, certificate validation, etc.
    }
    
    private func configureSecureStorage() {
        // Configure secure storage settings
        // This could include Keychain configuration, encryption settings, etc.
    }
    
    private func validateAppCheck(completion: @escaping (Result<Bool, SecurityError>) -> Void) {
        appCheck?.token(forcingRefresh: false) { token, error in
            if let error = error {
                completion(.failure(.appCheckFailed(error)))
            } else {
                completion(.success(true))
            }
        }
    }
}

// MARK: - Extensions

extension FirebaseSecurityManager {
    
    /// Check if security is properly configured
    /// - Returns: Configuration status
    public func isSecurityConfigured() -> Bool {
        return isConfigured
    }
    
    /// Get App Check token
    /// - Parameter completion: Completion handler
    public func getAppCheckToken(completion: @escaping (Result<String, SecurityError>) -> Void) {
        appCheck?.token(forcingRefresh: false) { token, error in
            if let error = error {
                completion(.failure(.appCheckFailed(error)))
            } else if let token = token {
                completion(.success(token.token))
            } else {
                completion(.failure(.appCheckFailed(NSError(domain: "Security", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))))
            }
        }
    }
    
    /// Validate network request
    /// - Parameters:
    ///   - url: URL to validate
    ///   - completion: Completion handler
    public func validateNetworkRequest(
        url: URL,
        completion: @escaping (Result<Bool, SecurityError>) -> Void
    ) {
        // Implement network request validation
        // This could include certificate pinning, URL validation, etc.
        completion(.success(true))
    }
    
    /// Secure data transmission
    /// - Parameters:
    ///   - data: Data to transmit
    ///   - completion: Completion handler
    public func secureDataTransmission(
        _ data: Data,
        completion: @escaping (Result<Data, SecurityError>) -> Void
    ) {
        // Implement secure data transmission
        // This could include encryption, signing, etc.
        completion(.success(data))
    }
}
