import Foundation

/// A compact JSON Web Token split into its parts, without any trust in its contents.
///
/// Parsing enforces a size limit (16 KiB), exactly three parts, unpadded base64url and JSON
/// objects for the header and payload. It does not check the signature: ``IDTokenVerifier``
/// does that.
public struct JSONWebToken: Sendable, Hashable {
    /// The decoded header.
    public let header: Header
    /// The payload bytes, as signed.
    public let payload: Data
    /// The signature bytes.
    public let signature: Data
    /// `base64url(header) + "." + base64url(payload)`: the bytes the signature covers.
    let signingInput: Data

    /// The header fields the package reads.
    public struct Header: Sendable, Hashable, Decodable {
        /// The signing algorithm: `RS256` for Firebase ID tokens, `none` for emulator tokens.
        public let alg: String
        /// The ID of the signing key.
        public let kid: String?
        public let typ: String?
    }

    /// Splits and decodes `compact`.
    public init(_ compact: String) throws {
        guard compact.utf8Count <= Limits.maxTokenBytes else {
            throw TokenError.malformed("longer than \(Limits.maxTokenBytes) bytes")
        }
        let parts = compact.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { throw TokenError.malformed("expected 3 parts, found \(parts.count)") }
        guard let headerData = Base64URL.decode(parts[0]), let payload = Base64URL.decode(parts[1]),
              let signature = Base64URL.decode(parts[2]) else {
            throw TokenError.malformed("a part is not base64url")
        }
        do {
            header = try JSONDecoder().decode(Header.self, from: headerData)
        } catch {
            throw TokenError.malformed("the header is not a JSON object with \"alg\"")
        }
        self.payload = payload
        self.signature = signature
        signingInput = Data("\(parts[0]).\(parts[1])".utf8)
    }

    /// The payload's claims. The token is not verified: do not base access decisions on them.
    public func claims() throws -> IDTokenClaims {
        do {
            return try JSONDecoder().decode(IDTokenClaims.self, from: payload)
        } catch let error as TokenError {
            throw error
        } catch {
            throw TokenError.malformed("the payload is not a JSON object of claims")
        }
    }
}

/// Unpadded base64url (RFC 7515 §2), strict: no padding, whitespace or other alphabets.
enum Base64URL {
    static func decode(_ text: Substring) -> Data? {
        guard text.utf8.allSatisfy(isAlphabet) else { return nil }
        // A length of 1 modulo 4 cannot come from any byte string.
        guard text.utf8.count % 4 != 1 else { return nil }
        var base64 = text.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.utf8.count % 4) % 4)
        return Data(base64Encoded: base64)
    }

    static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func isAlphabet(_ byte: UInt8) -> Bool {
        switch byte {
        case UInt8(ascii: "A")...UInt8(ascii: "Z"), UInt8(ascii: "a")...UInt8(ascii: "z"),
             UInt8(ascii: "0")...UInt8(ascii: "9"), UInt8(ascii: "-"), UInt8(ascii: "_"):
            true
        default:
            false
        }
    }
}
