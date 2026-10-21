<!-- i18n-source: README.md@9444151db75676a7995e80b9caace05a8fecbc34 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

iOSFirebaseTools ist ein Swift-Paket für Firebase Authentication und Cloud Firestore. Es spricht die
REST-APIs von Firebase per `URLSession` an, statt das Firebase SDK einzubetten. Gedacht ist es für
Code, in dem das SDK nicht passt oder nicht existiert: App Clips und Widgets mit knappem Größen-
und Speicherbudget, watchOS, Kommandozeilenwerkzeuge und Swift-Server, die das ID-Token prüfen
müssen, das eine App sendet. Es meldet Nutzer an und hält ihr Token aktuell, bildet
`Codable`-Modelle auf Firestore-Dokumente ab, läuft gegen die Firebase Local Emulator Suite und
verifiziert ID-Tokens auf einem Server. Außer dem SDK von Apple hat es keine Abhängigkeiten.

## Highlights

- **Anmeldung, die angemeldet bleibt** — E-Mail und Passwort, anonym, Sign in with Apple und
  Google; die Sitzung liegt im Schlüsselbund, und das ID-Token wird vor dem Ablauf erneuert, mit
  nur einer Anfrage für beliebig viele gleichzeitige Aufrufer.
- **Firestore mit eigenen Typen** — `Codable`-Modelle lesen, abfragen, schreiben, als Batch senden
  und in Transaktionen verarbeiten; `Date` wird zu einem Zeitstempel, und Server-Zeitstempel und
  Inkremente sind ein einziges Argument.
- **Fehler statt Abstürze** — eine Ganzzahl, die `Int64` überläuft, ein NaN in einem `Int`-Feld,
  ein Datum im Jahr 10000 oder eine Antwort von 20 MB löst einen typisierten Fehler aus; Pfade,
  Feldnamen und Grenzwerte werden vor dem Senden einer Anfrage gegen die Regeln von Firebase
  geprüft.
- **ID-Tokens auf deinem Server prüfen** — `IDTokenVerifier` wendet die Regeln von Firebase für
  RS256-Tokens mit den von Google veröffentlichten Schlüsseln an; die Admin SDKs tun das für
  andere Sprachen, aber nicht für Swift.
- **Logs ohne Geheimnisse** — Tokens, E-Mail-Adressen, Anfragekörper, Abfragewerte, ID-artige
  Pfadsegmente und die Meldungen des Servers erscheinen nicht in dem, was `print`, `dump`, Logs und
  der Debugger anzeigen; siehe [Was Logs zeigen](#was-logs-zeigen).
- **Durchgängig getestet** — 142 Swift-Testing-Tests, davon 10 gegen die Authentication- und
  Firestore-Emulatoren mit Security Rules, und fünf UI-Tests der Beispiel-App auf einem
  Simulator.

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Modul importieren**

```swift
import iOSFirebaseTools
```

**3. Verwenden**

Füge die `GoogleService-Info.plist` deines Projekts zum App-Target hinzu, aktiviere die
**Anonymous**-Anmeldung und lege in der [Firebase console](https://console.firebase.google.com)
eine Cloud-Firestore-Datenbank an, mit [Security Rules](Emulators/firestore.rules), die es
Nutzern erlauben, ihre eigenen Notizen zu schreiben. Ersetze dann die `ContentView.swift` einer
neuen iOS-App durch:

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

Starte die App und tippe auf den Button: Der Text zeigt `Saved notes/…`, und die Notiz erscheint
in der Konsole unter **Firestore Database**. Noch kein Firebase-Projekt? Derselbe Code läuft auch
gegen die Emulatoren auf deinem Mac; siehe [Mit den Emulatoren testen](#mit-den-emulatoren-testen).

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

## Verwendung

Die folgenden Beispiele sind aus
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift)
kopiert; die Beispiel-App und die Tests des Pakets kompilieren diese Datei, die Emulator-Tests
führen sie aus.

### Die Clients einmal konfigurieren

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

### Anmelden

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

`auth.idToken()` liefert ein Token, das noch mindestens fünf Minuten gültig ist, und erneuert es
bei Bedarf. Sign in with Apple läuft über `auth.signIn(with: .apple(idToken:rawNonce:))`, wobei
`AppleSignInNonce` die Nonce liefert; der ganze Ablauf steht in der Anleitung
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin).

### Dokumente lesen und schreiben

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

### Atomar schreiben

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### In einer Transaktion lesen und schreiben

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

Ändert ein anderer Schreibvorgang die Notiz zwischen dem Lesen und dem Commit, bricht Firestore den
Commit ab, und die Closure läuft erneut, standardmäßig bis zu fünfmal.

### Das Token auf deinem Server prüfen

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Mit den Emulatoren testen

Starte die Authentication- und Firestore-Emulatoren mit der [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes`; Java 21 oder neuer) und
richte die Clients auf sie aus. Eine Projekt-ID, die mit `demo-` beginnt, braucht kein
Firebase-Konto.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Eine iOS-App braucht außerdem `NSAllowsLocalNetworking` unter `NSAppTransportSecurity` in ihrer
Info.plist, weil die Emulatoren unverschlüsseltes HTTP sprechen. Für Unit-Tests ganz ohne Netzwerk
nimmt jeder Client einen `HTTPTransport` entgegen, den du ersetzen kannst.

## Demo

| Anmelden                                                    | Notizen in Firestore                                 | Konto und Token                                           |
| ----------------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------------------- |
| ![Anmeldebildschirm, hell](docs/images/sign-in-light.png)   | ![Notizliste, hell](docs/images/notes-light.png)     | ![Kontobildschirm, hell](docs/images/account-light.png)   |
| ![Anmeldebildschirm, dunkel](docs/images/sign-in-dark.png)  | ![Notizliste, dunkel](docs/images/notes-dark.png)    | ![Kontobildschirm, dunkel](docs/images/account-dark.png)  |

Die Screenshots stammen aus den UI-Tests der Beispiel-App auf einem iPhone-Simulator, die
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) gegen die Firebase Local
Emulator Suite ausführt: Der Test registriert sich, schreibt drei Notizen, pinnt eine (angepinnte
Notizen stehen zuerst) und öffnet den Kontobildschirm, auf dem das ID-Token nur als
`Secret(redacted, … characters)` erscheint.

Zum Ausprobieren führst du `scripts/start-emulators.sh` aus, öffnest `FirebaseLab.xcodeproj` in
[`Examples/FirebaseLab`](Examples/FirebaseLab), wählst einen iPhone-Simulator und drückst **Run**.
Die Einzelheiten stehen in [Examples/README.md](Examples/README.md), und das Kommandozeilenwerkzeug
`fbcheck` in [`Examples/ConfigCheck`](Examples/ConfigCheck) prüft Plists und verifiziert Tokens.

## Was Logs zeigen

Jeder Wert im Paket, der ein Token, ein Passwort oder personenbezogene Daten enthalten kann, wird in
geschwärzter Form ausgegeben. Was der Code nicht vollständig versteht, wird verborgen:

| Wert                                   | Angezeigt                                                  | Nie angezeigt                                                                |
| -------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `Secret`                               | seine Länge                                                | der Wert                                                                     |
| `AuthSession`                          | Anfang der Nutzer-ID, anonym oder nicht, Ablaufzeit        | Tokens, E-Mail-Adresse                                                       |
| `HTTPRequest`, `HTTPResponse`          | Methode, Host, Pfad, Abfragenamen, erlaubte Header, Status | Körper, Nutzerinformationen, Fragmente, Abfragewerte, ID-artige Pfadsegmente |
| `AuthError`, `FirestoreError`          | Code und HTTP-Status                                       | die Meldung des Servers (`message` im Code lesen)                            |
| `FirebaseProject`, `GoogleServiceInfo` | Projekt-ID, Datenbank, Bundle-ID                           | der API-Schlüssel                                                            |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

Namen werden nach Prozent-Dekodierung, NFKC und Groß-/Kleinschreibungs-Faltung verglichen, und ein
Name, der danach noch kein reines ASCII ist, etwa `şifre` oder ein `password` mit einem kyrillischen
Buchstaben, gilt als geheim. Körper werden nie geparst oder angezeigt. `RedactionPolicy` listet die
Header und Abfrageparameter auf, deren Werte deine eigenen Logs zeigen dürfen.

Das ist ein Sicherheitsnetz, keine Garantie: Es kann Text, den du selbst schreibst, nicht schwärzen,
und ein kurzes Geheimnis in einem URL-Pfad kann wie ein gewöhnliches Wort aussehen. Halte
Geheimnisse von vornherein aus Logs und URLs heraus. Der Artikel
[Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
enthält die vollständigen Regeln und Grenzen.

## Dokumentation

API-Referenz und Artikel:

- [API-Referenz](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, von `master` auf GitHub Pages veröffentlicht)
- Lokal baust du sie in Xcode mit **Product › Build Documentation** oder auf der Kommandozeile:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Anleitungen

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — das Paket hinzufügen, das Firebase-Projekt vorbereiten, anmelden und ein Dokument speichern
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — Anmeldung per E-Mail, anonym, mit Apple und Google, Fehler, die Sitzung im Schlüsselbund und aktuelle Tokens
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — Modelle, Abfragen, Schreibvorgänge, Transformationen, Batches, Transaktionen und die Grenzwerte, die der Client prüft
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — die Regeln von Firebase, Schlüssel-Caching, Claims und Zeitabweichung auf einem Swift-Server
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — die Local Emulator Suite, `emulators:exec` und Unit-Tests mit einem Test-Transport
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  — was Anfragen, Sitzungen und Fehler in Logs zeigen, die Erlaubnisliste und was nicht erkannt wird
  ([Quelle](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)).

## Voraussetzungen

| Plattform | Mindestversion        |
| --------- | --------------------- |
| iOS       | 17                    |
| macOS     | 14                    |
| tvOS      | 17                    |
| watchOS   | 10                    |
| visionOS  | 1                     |
| Toolchain | Swift 6.2 · Xcode 26+ |

Das Paket nutzt das Security-Framework und CryptoKit und lässt sich deshalb nicht unter Linux
bauen. Die CI baut mit dem Standard-Xcode des `macos-26`-Runner-Images von GitHub; entwickelt wird
das Paket mit Xcode 27. Die Emulator-Tests brauchen die Firebase CLI und Java 21 oder neuer.

## Architektur

- `Project/`: `FirebaseProject` (Projekt-ID, API-Schlüssel, Datenbank, Emulatoren) und
  `GoogleServiceInfo`, das die Plist liest und prüft.
- `Auth/`: `FirebaseAuthClient`, ein Actor über den REST-APIs von Identity Toolkit und Secure
  Token; `AuthSession` und der `SessionStore`, in dem sie gespeichert wird (Schlüsselbund oder
  Speicher); Anmeldedaten der Anbieter.
- `Firestore/`: `FirestoreClient`, ein `Sendable`-Struct über der Firestore-REST-API;
  `FirestoreValue` mit seiner JSON-Form, der `Codable`-Encoder und -Decoder, Pfade, Abfragen sowie
  `WriteBatch` und `FirestoreTransaction`. Alle Schreibvorgänge laufen über den `commit`-Endpunkt,
  sodass ein einzelner Schreibvorgang, ein Batch und eine Transaktion sich gleich verhalten.
- `Tokens/`: das Parsen von `JSONWebToken`, `IDTokenClaims` und `IDTokenVerifier` mit RSA-Schlüsseln
  aus dem JSON Web Key Set von Google.
- `Transport/`: das Protokoll `HTTPTransport` und seine `URLSession`-Implementierung, die einzige
  Stelle, die das Netzwerk berührt.
- `Support/`: `Secret`, `ValidationError` und die Schwärzungsregeln, die jede Textform gemeinsam
  nutzt.
- Eingaben von außerhalb des Prozesses sind begrenzt: Antwortkörper (16 MiB), Tokens (16 KiB),
  Plists (64 KiB), Verschachtelungstiefe, Zahlenbereiche vor jeder Umwandlung und
  Emulator-Adressen (nur `host:port`).

Die Tests lokal ausführen:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Roadmap

- Das Paket zum Swift Package Index hinzufügen; `.spi.yml` liegt bereits im Repository.
- Anbieter mit einem bestehenden Nutzer verknüpfen und E-Mail-Verifizierung.
- Ein Linux-Build von `IDTokenVerifier` auf Basis von swift-crypto.

Echtzeit-Listener und der Offline-Cache sind nicht geplant: Sie brauchen die
gRPC-Streaming-Verbindung von Firestore, die die REST-API nicht anbietet.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
