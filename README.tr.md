<!-- i18n-source: README.md@9444151db75676a7995e80b9caace05a8fecbc34 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

iOSFirebaseTools, Firebase Authentication ve Cloud Firestore için yazılmış bir Swift paketidir.
Firebase SDK'sını uygulamaya gömmek yerine Firebase'in REST API'leriyle `URLSession` üzerinden
konuşur. SDK'nın uymadığı ya da hiç bulunmadığı yerler için tasarlanmıştır: boyut ve bellek
bütçesi dar olan App Clip'ler ve widget'lar, watchOS, komut satırı araçları ve bir uygulamanın
gönderdiği ID token'ı doğrulaması gereken Swift sunucuları. Kullanıcıların oturum açmasını sağlar
ve token'larını güncel tutar, `Codable` modellerini Firestore belgelerine eşler, Firebase Local
Emulator Suite'e karşı çalışır ve sunucuda ID token'ları doğrular. Apple'ın SDK'sı dışında hiçbir
bağımlılığı yoktur.

## Öne çıkanlar

- **Oturumu açık kalan giriş** — e-posta ve parola, anonim, Sign in with Apple ve Google; oturum
  Keychain'de saklanır ve ID token süresi dolmadan yenilenir; kaç eşzamanlı çağıran olursa olsun
  tek bir istek gönderilir.
- **Kendi türlerinizle Firestore** — `Codable` modellerini okuyun, sorgulayın, yazın, toplu yazın ve
  bir işlem (transaction) içinde okuyup yazın; `Date` zaman damgasına dönüşür, sunucu zaman
  damgaları ve artırımlar tek bir argümandır.
- **Çökme yerine hata** — `Int64`'ü aşan bir tamsayı, `Int` alanındaki bir NaN, 10000. yıldaki
  bir tarih ya da 20 MB'lık bir yanıt, türü belli bir hata fırlatır; yollar, alan adları ve
  sınırlar istek gönderilmeden önce Firebase'in kurallarına göre denetlenir.
- **ID token'lar sunucunuzda doğrulanır** — `IDTokenVerifier`, Google'ın yayımladığı anahtarlarla
  RS256 token'lar için Firebase'in kurallarını uygular; Admin SDK'lar bunu diğer diller için
  yapar, ancak Swift için yapmaz.
- **Günlüklerde sır yok** — token'lar, e-posta adresleri, istek gövdeleri, sorgu değerleri, kimliğe
  benzeyen yol parçaları ve sunucunun mesajları `print`, `dump`, günlüklerin ve hata ayıklayıcının
  gösterdiği çıktıya girmez; bkz. [Günlüklerde neler görünür](#günlüklerde-neler-görünür).
- **Uçtan uca test edilmiş** — 142 Swift Testing testi; bunların 10'u Security Rules ile
  Authentication ve Firestore emülatörlerine karşı çalışır; ayrıca örnek uygulamanın bir
  simülatörde çalışan beş arayüz testi vardır.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Modülü içe aktarın**

```swift
import iOSFirebaseTools
```

**3. Kullanın**

Projenizin `GoogleService-Info.plist` dosyasını uygulama hedefine ekleyin, **Anonymous** girişi
etkinleştirin ve [Firebase console](https://console.firebase.google.com)'da bir Cloud Firestore
veritabanı oluşturun; kullanıcıların kendi notlarını yazabilmesini sağlayan
[Security Rules](Emulators/firestore.rules) kurallarını da tanımlayın. Ardından yeni bir iOS
uygulamasının `ContentView.swift` dosyasını şununla değiştirin:

```swift
import iOSFirebaseTools
import SwiftUI

struct ContentView: View {
    @State private var status = "Nothing saved yet"

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
            Button("Save a note to Firestore") {
                Task { status = await saveFirstNote() }
            }
        }
        .padding()
    }
}

func saveFirstNote() async -> String {
    do {
        // Reads the GoogleService-Info.plist in your app target.
        let project = try GoogleServiceInfo.inMainBundle().project()
        let auth = FirebaseAuthClient(project: project)
        let firestore = FirestoreClient(project: project, credentials: .user(auth))

        let session = try await auth.signInAnonymously()
        let note = ["text": "Hello, Firestore", "ownerID": session.userID]
        let path = try await firestore.add(note, to: "notes")
        return "Saved \(path)"
    } catch {
        return "Could not save: \(error)"
    }
}
```

Uygulamayı çalıştırıp düğmeye dokunun: metin `Saved notes/…` olarak değişir ve not, konsoldaki
**Firestore Database** altında görünür. Henüz bir Firebase projeniz yok mu? Aynı kod Mac'inizdeki
emülatörlere karşı da çalışır; bkz. [Emülatörlerle test etme](#emülatörlerle-test-etme).

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "iOSFirebaseTools", package: "iOSFirebaseTools")
    ])
]
```

## Kullanım

Aşağıdaki örnekler,
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift)
dosyasından kopyalanmıştır; bu dosyayı örnek uygulama ve paketin testleri derler, emülatör testleri
ise çalıştırır.

### İstemcileri bir kez yapılandırın

```swift
func makeClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // The GoogleService-Info.plist you downloaded from the Firebase console.
    let project = try GoogleServiceInfo.inMainBundle().project()
    let auth = FirebaseAuthClient(project: project) // keeps the session in the keychain
    let firestore = FirestoreClient(project: project, credentials: .user(auth))
    return (auth, firestore)
}

func checkConfiguration() throws {
    let info = try GoogleServiceInfo.inMainBundle()
    for problem in info.problems(bundleIdentifier: Bundle.main.bundleIdentifier) {
        // For example: BUNDLE_ID is com.example.notes but the app is com.example.notes.dev
        assertionFailure(problem.description)
    }
}
```

### Oturum açma

```swift
func signIn(with auth: FirebaseAuthClient, email: String, password: String) async throws -> AuthSession {
    do {
        return try await auth.signIn(email: email, password: password)
    } catch let error as AuthError where error.code == .invalidLoginCredentials {
        print("Wrong e-mail or password")
        throw error
    } catch let error as AuthError where error.code == .tooManyAttempts {
        print("Too many attempts; try again later")
        throw error
    }
}

func currentUserID(with auth: FirebaseAuthClient) async throws -> String {
    // The session saved by an earlier launch, or a new anonymous user.
    if let session = try await auth.restoreSession() { return session.userID }
    return try await auth.signInAnonymously().userID
}
```

`auth.idToken()`, en az beş dakika daha geçerli olan bir token döndürür; gerekirse onu yeniler.
Sign in with Apple için `auth.signIn(with: .apple(idToken:rawNonce:))` kullanılır, nonce için de
`AppleSignInNonce` vardır; tüm akış için
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
rehberine bakın.

### Belge okuma ve yazma

```swift
struct Note: Codable, Sendable, Equatable {
    var text: String
    var ownerID: String
    var pinned = false
    var createdAt: Date? // set by the server
}

func addNote(_ text: String, ownerID: String, to firestore: FirestoreClient) async throws -> String {
    let note = Note(text: text, ownerID: ownerID)
    return try await firestore.add(note, to: "notes", transforms: ["createdAt": .serverTimestamp])
}

func loadNotes(ownerID: String, from firestore: FirestoreClient) async throws -> [FirestoreDocument<Note>] {
    let query = FirestoreQuery(collection: "notes")
        .filter("ownerID", .equal, ownerID)
        .limit(100)
    return try await firestore.documents(matching: query, as: Note.self)
}

func pinNote(at path: String, in firestore: FirestoreClient) async throws {
    try await firestore.update(path, fields: ["pinned": true])
}
```

### Atomik yazma

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Bir işlem içinde okuma ve yazma

```swift
/// Flips `pinned` even when two devices tap at once: the read and the write happen together.
func togglePin(at path: String, in firestore: FirestoreClient) async throws -> Bool? {
    try await firestore.runTransaction { transaction in
        guard let note = try await transaction.document(path, as: Note.self) else { return nil }
        try transaction.update(path, fields: ["pinned": .bool(!note.data.pinned)])
        return !note.data.pinned
    }
}
```

Not, okuma ile commit arasında başka bir yazma tarafından değiştirilirse Firestore commit'i iptal
eder ve closure yeniden çalışır; varsayılan olarak en fazla beş kez.

### Token'ı sunucunuzda doğrulama

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Emülatörlerle test etme

[Firebase CLI](https://firebase.google.com/docs/cli) ile Authentication ve Firestore
emülatörlerini başlatın (`firebase emulators:start --only auth,firestore --project demo-notes`;
Java 21 veya üstü gerekir) ve istemcileri bunlara yönlendirin. `demo-` ile başlayan bir proje
kimliği için Firebase hesabı gerekmez.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Emülatörler düz HTTP sunduğu için bir iOS uygulamasının Info.plist dosyasında
`NSAppTransportSecurity` altında `NSAllowsLocalNetworking` anahtarı da bulunmalıdır. Ağa hiç
çıkmayan birim testleri için her istemci, değiştirebileceğiniz bir `HTTPTransport` alır.

## Demo

| Oturum açma                                               | Firestore'daki notlar                               | Hesap ve token                                          |
| --------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| ![Oturum açma ekranı, açık tema](docs/images/sign-in-light.png) | ![Not listesi, açık tema](docs/images/notes-light.png) | ![Hesap ekranı, açık tema](docs/images/account-light.png) |
| ![Oturum açma ekranı, koyu tema](docs/images/sign-in-dark.png)  | ![Not listesi, koyu tema](docs/images/notes-dark.png)  | ![Hesap ekranı, koyu tema](docs/images/account-dark.png)  |

Ekran görüntüleri, örnek uygulamanın bir iPhone simülatöründe çalışan arayüz testlerinden alınmıştır;
testler [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) ile Firebase Local
Emulator Suite'e karşı çalıştırılır: test kayıt olur, üç not yazar, birini sabitler (sabitlenen
notlar en üstte görünür) ve ID token'ın yalnızca `Secret(redacted, … characters)` olarak göründüğü
hesap ekranını açar.

Kendiniz denemek için `scripts/start-emulators.sh` komutunu çalıştırın,
[`Examples/FirebaseLab`](Examples/FirebaseLab) içindeki `FirebaseLab.xcodeproj` dosyasını açın,
bir iPhone simülatörü seçin ve **Run**'a basın. Ayrıntılar [Examples/README.md](Examples/README.md)
dosyasındadır; [`Examples/ConfigCheck`](Examples/ConfigCheck) içindeki `fbcheck` komut satırı aracı
ise plist dosyalarını denetler ve token'ları doğrular.

## Günlüklerde neler görünür

Pakette bir token, parola ya da kişisel veri tutabilen her değer, gizlenmiş bir biçimde yazdırılır.
Kodun tam olarak anlamadığı şey gizlenir:

| Değer                                  | Gösterilen                                                           | Asla gösterilmeyen                                                                         |
| -------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `Secret`                               | uzunluğu                                                             | değeri                                                                                     |
| `AuthSession`                          | kullanıcı kimliğinin başı, anonim olup olmadığı, son kullanma zamanı | token'lar, e-posta adresi                                                                  |
| `HTTPRequest`, `HTTPResponse`          | metot, ana makine, yol, sorgu adları, izin verilen başlıklar, durum  | gövdeler, kullanıcı bilgisi, fragment'ler, sorgu değerleri, kimliğe benzeyen yol parçaları |
| `AuthError`, `FirestoreError`          | kod ve HTTP durumu                                                   | sunucunun mesajı (kodda `message` okunur)                                                  |
| `FirebaseProject`, `GoogleServiceInfo` | proje kimliği, veritabanı, bundle ID                                 | API anahtarı                                                                               |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

Adlar, yüzde kodlaması çözüldükten, NFKC uygulandıktan ve büyük/küçük harf farkı kaldırıldıktan
sonra karşılaştırılır; hâlâ düz ASCII olmayan bir ad, örneğin `şifre` ya da Kiril harfi içeren bir
`password`, gizli kabul edilir. Gövdeler hiçbir zaman ayrıştırılmaz ya da gösterilmez.
`RedactionPolicy`, değerleri kendi günlüklerinizde görünebilecek başlıkları ve sorgu parametrelerini
listeler.

Bu bir güvenlik ağıdır, garanti değildir: kendi yazdığınız metni gizleyemez ve bir URL yolundaki
kısa bir sır sıradan bir kelimeye benzeyebilir. Sırları en baştan günlüklerin ve URL'lerin dışında
tutun. Tüm kurallar ve sınırlar için
[Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
makalesine bakın.

## Dokümantasyon

API başvuru belgeleri ve makaleler:

- [API başvurusu](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC; `master` dalından GitHub Pages'e yayımlanır)
- Xcode'da **Product › Build Documentation** ile ya da komut satırından yerel olarak derleyin:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Rehberler

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — paketi ekleme, Firebase projesini hazırlama, oturum açma ve bir belge kaydetme
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — e-posta, anonim, Apple ve Google ile giriş, hatalar, Keychain oturumu ve güncel token'lar
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — modeller, sorgular, yazma işlemleri, dönüşümler, toplu yazmalar, işlemler ve istemcinin denetlediği sınırlar
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — bir Swift sunucusunda Firebase'in kuralları, anahtar önbelleği, claim'ler ve saat farkı toleransı
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — Local Emulator Suite, `emulators:exec` ve test amaçlı bir transport ile birim testleri
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  — istek, oturum ve hataların günlüklerde ne gösterdiği, izin listesi ve nelerin bulunamadığı
  ([kaynak](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)).

## Gereksinimler

| Platform     | En düşük sürüm        |
| ------------ | --------------------- |
| iOS          | 17                    |
| macOS        | 14                    |
| tvOS         | 17                    |
| watchOS      | 10                    |
| visionOS     | 1                     |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

Paket Security çerçevesini ve CryptoKit'i kullandığı için Linux'ta derlenmez. CI, GitHub'ın
`macos-26` runner imajındaki varsayılan Xcode ile derleme yapar; paket Xcode 27 ile geliştirilir.
Emülatör testleri için Firebase CLI ve Java 21 veya üstü gerekir.

## Mimari

- `Project/`: `FirebaseProject` (proje kimliği, API anahtarı, veritabanı, emülatörler) ve plist
  dosyasını okuyup denetleyen `GoogleServiceInfo`.
- `Auth/`: Identity Toolkit ve Secure Token REST API'leri üzerinde çalışan bir actor olan
  `FirebaseAuthClient`; `AuthSession` ve kaydedildiği `SessionStore` (Keychain veya bellek);
  sağlayıcı kimlik bilgileri.
- `Firestore/`: Firestore REST API'si üzerinde çalışan `Sendable` bir struct olan `FirestoreClient`;
  JSON biçimiyle `FirestoreValue`, `Codable` encoder ve decoder, yollar, sorgular, `WriteBatch` ve
  `FirestoreTransaction`. Tüm yazma işlemleri `commit` uç noktasından geçer; bu yüzden tek bir
  yazma, toplu yazma ve işlem aynı şekilde davranır.
- `Tokens/`: `JSONWebToken` ayrıştırma, `IDTokenClaims` ve Google'ın JSON Web Key Set'indeki RSA
  anahtarlarını kullanan `IDTokenVerifier`.
- `Transport/`: `HTTPTransport` protokolü ve onun `URLSession` gerçeklemesi; ağa dokunan tek yer
  burasıdır.
- `Support/`: `Secret`, `ValidationError` ve her metin biçiminin paylaştığı gizleme kuralları.
- Süreç dışından gelen girdi sınırlıdır: yanıt gövdeleri (16 MiB), token'lar (16 KiB), plist
  dosyaları (64 KiB), iç içe geçme derinliği, dönüştürmeden önce sayı aralıkları ve emülatör
  adresleri (yalnızca `host:port`).

Testleri yerel olarak çalıştırın:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Yol haritası

- Paketi Swift Package Index'e eklemek; `.spi.yml` depoda zaten var.
- Sağlayıcıları var olan bir kullanıcıya bağlama ve e-posta doğrulama.
- `IDTokenVerifier`'ın swift-crypto üzerinde bir Linux sürümü.

Gerçek zamanlı dinleyiciler ve çevrimdışı önbellek planlanmıyor: bunlar için Firestore'un gRPC
akış bağlantısı gerekir, REST API'si ise bunu sunmaz.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
