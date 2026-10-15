import Foundation
import Security
@testable import iOSFirebaseTools

/// Signs Firebase-shaped ID tokens with a fresh RSA key, the way Google's token service does.
struct TokenFactory {
    let privateKey: SecKey
    let kid: String

    init(bits: Int = 2_048, kid: String = "test-key-1") throws {
        let attributes: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: bits]
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        privateKey = key
        self.kid = kid
    }

    /// The public key in PKCS #1 DER.
    var publicKeyDER: Data {
        SecKeyCopyExternalRepresentation(SecKeyCopyPublicKey(privateKey)!, nil)! as Data
    }

    var publicKey: RSAPublicKey {
        get throws { try RSAPublicKey(pkcs1: publicKeyDER) }
    }

    /// The key as a JSON Web Key, with `n` and `e` read from the DER.
    var jwk: [String: String] {
        let (n, e) = Self.modulusAndExponent(publicKeyDER)
        return ["kty": "RSA", "alg": "RS256", "use": "sig", "kid": kid, "n": Fixtures.base64URL(n), "e": Fixtures.base64URL(e)]
    }

    static func claims(projectID: String = "demo-fixture", now: Date, lifetime: TimeInterval = 3_600) -> [String: Any] {
        let seconds = now.timeIntervalSince1970.rounded(.down)
        return [
            "iss": "https://securetoken.google.com/\(projectID)", "aud": projectID, "sub": "user-1", "user_id": "user-1",
            "iat": seconds, "auth_time": seconds, "exp": seconds + lifetime, "email": "ada@example.com",
            "email_verified": true, "firebase": ["sign_in_provider": "password", "identities": [:] as [String: Any]],
            "admin": true,
        ]
    }

    func token(_ claims: [String: Any], header: [String: Any]? = nil) throws -> String {
        let headerJSON = try JSONSerialization.data(withJSONObject: header ?? ["alg": "RS256", "kid": kid, "typ": "JWT"], options: [.sortedKeys])
        let payload = try JSONSerialization.data(withJSONObject: claims, options: [.sortedKeys])
        let signingInput = "\(Fixtures.base64URL(headerJSON)).\(Fixtures.base64URL(payload))"
        return "\(signingInput).\(Fixtures.base64URL(try sign(Data(signingInput.utf8))))"
    }

    func sign(_ data: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, data as CFData, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return signature as Data
    }

    /// Reads SEQUENCE { INTEGER n, INTEGER e }.
    static func modulusAndExponent(_ der: Data) -> (Data, Data) {
        var index = der.startIndex
        func readLength() -> Int {
            let first = der[index]
            index += 1
            guard first & 0x80 != 0 else { return Int(first) }
            var length = 0
            for _ in 0..<Int(first & 0x7F) {
                length = length << 8 | Int(der[index])
                index += 1
            }
            return length
        }
        func readInteger() -> Data {
            index += 1 // INTEGER tag
            let length = readLength()
            defer { index += length }
            return Data(der[index..<index + length])
        }
        index += 1 // SEQUENCE tag
        _ = readLength()
        return (readInteger(), readInteger())
    }
}
