<!-- i18n-source: README.md@e58ec5fc64f013f130f40242c1352ea03fa05302 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Dernière version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

iOSFirebaseTools est un package Swift pour Firebase Authentication et Cloud Firestore. Il appelle
les API REST de Firebase avec `URLSession` au lieu d’embarquer le SDK Firebase. Il s’adresse au
code pour lequel le SDK ne convient pas ou n’existe pas : App Clips et widgets aux budgets de
taille et de mémoire serrés, watchOS, outils en ligne de commande et serveurs Swift qui doivent
vérifier l’ID token envoyé par une app. Il connecte les utilisateurs et garde leur token à jour,
associe des modèles `Codable` à des documents Firestore, fonctionne avec la Firebase Local
Emulator Suite et vérifie les ID tokens sur un serveur. Il n’a aucune dépendance en dehors du SDK
d’Apple.

## Points forts

- **Une connexion qui reste ouverte** — e-mail et mot de passe, anonyme, Sign in with Apple et
  Google ; la session est conservée dans le trousseau et l’ID token est renouvelé avant son
  expiration, avec une seule requête quel que soit le nombre d’appelants concurrents.
- **Firestore avec vos propres types** — lisez, interrogez, écrivez et regroupez en lots des
  modèles `Codable` ; `Date` devient un horodatage, et les horodatages serveur et les incréments
  tiennent en un seul argument.
- **Des erreurs plutôt que des plantages** — un entier qui dépasse `Int64`, un NaN dans un champ
  `Int`, une date de l’an 10000 ou une réponse de 20 Mo lèvent une erreur typée ; les chemins, les
  noms de champs et les limites sont vérifiés d’après les règles de Firebase avant l’envoi d’une
  requête.
- **ID tokens vérifiés sur votre serveur** — `IDTokenVerifier` applique les règles de Firebase pour
  les tokens RS256 avec les clés publiées par Google, ce que les SDK Admin font pour d’autres
  langages mais pas pour Swift.
- **Les tokens ne s’impriment jamais** — les sessions et les tokens n’affichent que leur longueur
  dans `print`, `dump`, les journaux et le débogueur.
- **Testé de bout en bout** — 105 tests Swift Testing, dont 9 contre les émulateurs Authentication
  et Firestore avec des Security Rules, et cinq tests d’interface de l’app d’exemple sur un
  simulateur.

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Importer le module**

```swift
import iOSFirebaseTools
```

**3. L’utiliser**

Ajoutez le `GoogleService-Info.plist` de votre projet à la cible de l’app, activez la connexion
**Anonymous** et créez une base Cloud Firestore dans la
[Firebase console](https://console.firebase.google.com), avec des
[Security Rules](Emulators/firestore.rules) qui permettent aux utilisateurs d’écrire leurs propres
notes. Remplacez ensuite le `ContentView.swift` d’une nouvelle app iOS par :

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

Lancez l’app et touchez le bouton : le texte affiche `Saved notes/…` et la note apparaît sous
**Firestore Database** dans la console. Pas encore de projet Firebase ? Le même code fonctionne
avec les émulateurs sur votre Mac ; voir [Tester avec les émulateurs](#tester-avec-les-émulateurs).

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

## Utilisation

Les exemples ci-dessous sont copiés depuis
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift),
que l’app d’exemple et les tests du package compilent et que les tests avec émulateurs exécutent.

### Configurer les clients une seule fois

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

### Se connecter

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

`auth.idToken()` renvoie un token valide pendant au moins cinq minutes encore, en le renouvelant au
besoin. Sign in with Apple s’utilise avec `auth.signIn(with: .apple(idToken:rawNonce:))`, avec
`AppleSignInNonce` pour le nonce ; le guide
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
décrit le parcours complet.

### Lire et écrire des documents

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

### Écrire de manière atomique

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Vérifier le token sur votre serveur

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Tester avec les émulateurs

Démarrez les émulateurs Authentication et Firestore avec la [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes` ; Java 21 ou plus récent),
puis faites pointer les clients vers eux. Un ID de projet qui commence par `demo-` ne nécessite
aucun compte Firebase.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Une app iOS a aussi besoin de `NSAllowsLocalNetworking` sous `NSAppTransportSecurity` dans son
Info.plist, car les émulateurs servent du HTTP non chiffré. Pour des tests unitaires sans aucun
réseau, chaque client accepte un `HTTPTransport` que vous pouvez remplacer.

## Démo

| Connexion                                                   | Notes dans Firestore                                   | Compte et token                                            |
| ----------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------- |
| ![Écran de connexion, clair](docs/images/sign-in-light.png) | ![Liste des notes, clair](docs/images/notes-light.png) | ![Écran du compte, clair](docs/images/account-light.png)   |
| ![Écran de connexion, sombre](docs/images/sign-in-dark.png) | ![Liste des notes, sombre](docs/images/notes-dark.png) | ![Écran du compte, sombre](docs/images/account-dark.png)   |

Les captures d’écran proviennent des tests d’interface de l’app d’exemple sur un simulateur iPhone,
exécutés contre la Firebase Local Emulator Suite par
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) : le test crée un compte, écrit
trois notes, en épingle une (les notes épinglées passent en premier) et ouvre l’écran du compte,
où l’ID token n’apparaît que sous la forme `Secret(redacted, … characters)`.

Pour l’essayer vous-même, lancez `scripts/start-emulators.sh`, ouvrez `FirebaseLab.xcodeproj` dans
[`Examples/FirebaseLab`](Examples/FirebaseLab), choisissez un simulateur iPhone et appuyez sur
**Run**. [Examples/README.md](Examples/README.md) donne les détails, et l’outil en ligne de commande
`fbcheck` de [`Examples/ConfigCheck`](Examples/ConfigCheck) contrôle des plists et vérifie des tokens.

## Documentation

Référence de l’API et articles :

- [Référence de l’API](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, publiée sur GitHub Pages depuis `master`)
- Générez-la en local dans Xcode avec **Product › Build Documentation**, ou en ligne de commande :

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — ajouter le package, préparer le projet Firebase, se connecter et enregistrer un document
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — connexion par e-mail, anonyme, Apple et Google, erreurs, session dans le trousseau et tokens à jour
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — modèles, requêtes, écritures, transformations, lots et limites vérifiées par le client
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — les règles de Firebase, le cache des clés, les claims et le décalage d’horloge sur un serveur Swift
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — la Local Emulator Suite, `emulators:exec` et les tests unitaires avec un transport de test
  ([source](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).

## Prérequis

| Plateforme      | Version minimale      |
| --------------- | --------------------- |
| iOS             | 17                    |
| macOS           | 14                    |
| tvOS            | 17                    |
| watchOS         | 10                    |
| visionOS        | 1                     |
| Chaîne d’outils | Swift 6.2 · Xcode 26+ |

Le package utilise le framework Security et CryptoKit ; il ne se compile donc pas sous Linux. La CI
compile avec le Xcode par défaut de l’image de runner `macos-26` de GitHub ; le package est
développé avec Xcode 27. Les tests avec émulateurs nécessitent la Firebase CLI et Java 21 ou plus
récent.

## Architecture

- `Project/` : `FirebaseProject` (ID du projet, clé d’API, base de données, émulateurs) et
  `GoogleServiceInfo`, qui lit et contrôle le plist.
- `Auth/` : `FirebaseAuthClient`, un actor au-dessus des API REST Identity Toolkit et Secure Token ;
  `AuthSession` et le `SessionStore` où elle est enregistrée (trousseau ou mémoire) ; identifiants
  des fournisseurs.
- `Firestore/` : `FirestoreClient`, un struct `Sendable` au-dessus de l’API REST de Firestore ;
  `FirestoreValue` avec sa forme JSON, l’encodeur et le décodeur `Codable`, les chemins, les
  requêtes et `WriteBatch`. Toutes les écritures passent par le endpoint `commit` : une écriture
  seule et un lot se comportent donc de la même façon.
- `Tokens/` : l’analyse de `JSONWebToken`, `IDTokenClaims` et `IDTokenVerifier` avec les clés RSA du
  JSON Web Key Set de Google.
- `Transport/` : le protocole `HTTPTransport` et son implémentation `URLSession`, le seul endroit
  qui accède au réseau.
- Les entrées venant de l’extérieur du processus sont bornées : corps de réponse (16 MiB), tokens
  (16 KiB), plists (64 KiB), profondeur d’imbrication, plages de nombres avant toute conversion et
  adresses d’émulateur (`host:port` uniquement).

Lancez les tests en local :

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Feuille de route

- Ajouter le package au Swift Package Index ; `.spi.yml` est déjà dans le dépôt.
- Les transactions Firestore (`beginTransaction` et un commit avec la transaction).
- Lier des fournisseurs à un utilisateur existant, et vérifier l’e-mail.
- Une version Linux de `IDTokenVerifier` sur swift-crypto.

Les listeners en temps réel et le cache hors ligne ne sont pas prévus : ils nécessitent la connexion
de streaming gRPC de Firestore, que l’API REST n’offre pas.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
