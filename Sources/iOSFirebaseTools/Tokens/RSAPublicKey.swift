import Foundation
import Security

/// An RSA public key for checking RS256 signatures.
public struct RSAPublicKey: @unchecked Sendable {
    // SecKey is immutable and thread-safe once created.
    let key: SecKey

    /// Creates a key from the modulus `n` and exponent `e` of a JSON Web Key (RFC 7518 §6.3),
    /// both base64url.
    public init(modulus: String, exponent: String) throws {
        guard let modulusBytes = Base64URL.decode(Substring(modulus)),
              let exponentBytes = Base64URL.decode(Substring(exponent)) else {
            throw TokenError.keysUnavailable("the key is not base64url")
        }
        let n = Self.stripLeadingZeros(modulusBytes)
        let e = Self.stripLeadingZeros(exponentBytes)
        // 2048 to 4096 bits: smaller keys are unsafe, larger ones are not used by Google.
        guard (256...512).contains(n.count), (1...8).contains(e.count) else {
            throw TokenError.keysUnavailable("unsupported RSA key size")
        }
        try self.init(pkcs1: DER.sequence([DER.unsignedInteger(n), DER.unsignedInteger(e)]))
    }

    /// Creates a key from a PKCS #1 `RSAPublicKey` in DER.
    public init(pkcs1 der: Data) throws {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(der as CFData, attributes as CFDictionary, &error) else {
            throw TokenError.keysUnavailable("the RSA key could not be read")
        }
        self.key = key
    }

    /// `true` when `signature` is a valid RSASSA-PKCS1-v1_5 SHA-256 signature of `message`.
    func isValidSignature(_ signature: Data, for message: Data) -> Bool {
        SecKeyVerifySignature(
            key, .rsaSignatureMessagePKCS1v15SHA256, message as CFData, signature as CFData, nil
        )
    }

    private static func stripLeadingZeros(_ data: Data) -> Data {
        Data(data.drop { $0 == 0 })
    }
}

/// The few DER encodings a PKCS #1 public key needs.
enum DER {
    static func unsignedInteger(_ magnitude: Data) -> Data {
        // A leading 0 keeps a high first bit from reading as a negative number.
        let content = (magnitude.first ?? 0) & 0x80 != 0 ? Data([0]) + magnitude : magnitude
        return Data([0x02]) + length(content.count) + content
    }

    static func sequence(_ elements: [Data]) -> Data {
        let content = elements.reduce(Data(), +)
        return Data([0x30]) + length(content.count) + content
    }

    static func length(_ count: Int) -> Data {
        if count < 0x80 { return Data([UInt8(count)]) }
        var bytes: [UInt8] = []
        var remaining = count
        while remaining > 0 {
            bytes.insert(UInt8(remaining & 0xFF), at: 0)
            remaining >>= 8
        }
        return Data([0x80 | UInt8(bytes.count)] + bytes)
    }
}
