<!-- i18n-source: README.md@57ac1265fcedc8b81a6c8a43c1038fb109899da4 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

iOSFirebaseTools es un paquete de Swift para Firebase Authentication y Cloud Firestore que usa las
API REST de Firebase mediante `URLSession` en lugar de incluir el SDK de Firebase. Está pensado para
el código en el que el SDK no encaja o no existe: App Clips y widgets con presupuestos ajustados de
tamaño y memoria, watchOS, herramientas de línea de comandos y servidores Swift que necesitan
comprobar el ID token que envía una app. Inicia sesión de los usuarios y mantiene vigente su token,
asigna modelos `Codable` a documentos de Firestore, funciona con Firebase Local Emulator Suite y
verifica ID tokens en un servidor. No tiene dependencias fuera del SDK de Apple.

## Lo más destacado

- **Inicio de sesión que se mantiene** — correo y contraseña, anónimo, Sign in with Apple y Google;
  la sesión se guarda en el llavero y el ID token se renueva antes de que caduque, con una sola
  petición sin importar cuántos llamantes concurrentes haya.
- **Firestore con tus propios tipos** — lee, consulta, escribe y agrupa en lotes modelos `Codable`;
  `Date` se convierte en una marca de tiempo, y las marcas de tiempo del servidor y los
  incrementos se indican con un solo argumento.
- **Errores en lugar de fallos** — un entero que desborda `Int64`, un NaN en un campo `Int`, una
  fecha del año 10000 o una respuesta de 20 MB lanzan un error tipado; las rutas, los nombres de
  campo y los límites se comprueban con las reglas de Firebase antes de enviar una petición.
- **ID tokens comprobados en tu servidor** — `IDTokenVerifier` aplica las reglas de Firebase para
  tokens RS256 con las claves publicadas por Google, algo que los SDK de administración ofrecen
  para otros lenguajes pero no para Swift.
- **Los tokens nunca se imprimen** — las sesiones y los tokens solo muestran su longitud en
  `print`, `dump`, los registros y el depurador.
- **Probado de principio a fin** — 104 pruebas de Swift Testing, 9 de ellas contra los emuladores de
  Authentication y Firestore con Security Rules, y cinco pruebas de interfaz de la app de ejemplo
  en un simulador.

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Importa el módulo**

```swift
import iOSFirebaseTools
```

**3. Úsalo**

Añade el `GoogleService-Info.plist` de tu proyecto al target de la app, activa el inicio de sesión
**Anonymous** y crea una base de datos de Cloud Firestore en la
[Firebase console](https://console.firebase.google.com), con
[Security Rules](Emulators/firestore.rules) que permitan a los usuarios escribir sus propias notas.
Después, sustituye el `ContentView.swift` de una app de iOS nueva por esto:

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

Ejecuta la app y pulsa el botón: el texto muestra `Saved notes/…` y la nota aparece en
**Firestore Database** en la consola. ¿Todavía no tienes un proyecto de Firebase? El mismo código
funciona con los emuladores en tu Mac; consulta
[Pruebas con los emuladores](#pruebas-con-los-emuladores).

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

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

## Uso

Los ejemplos siguientes están copiados de
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift),
que compilan la app de ejemplo y las pruebas del paquete, y que ejecutan las pruebas con emuladores.

### Configura los clientes una sola vez

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

### Inicio de sesión

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

`auth.idToken()` devuelve un token que sigue siendo válido durante al menos cinco minutos más y, si
hace falta, lo renueva. Sign in with Apple se hace con `auth.signIn(with: .apple(idToken:rawNonce:))`,
con `AppleSignInNonce` para el nonce; la guía
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
explica el flujo completo.

### Leer y escribir documentos

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

### Escribir de forma atómica

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Comprobar el token en tu servidor

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Pruebas con los emuladores

Inicia los emuladores de Authentication y Firestore con la [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes`; requiere Java 21 o
posterior) y apunta los clientes a ellos. Un ID de proyecto que empiece por `demo-` no necesita una
cuenta de Firebase.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Una app de iOS también necesita `NSAllowsLocalNetworking` dentro de `NSAppTransportSecurity` en su
Info.plist, porque los emuladores sirven HTTP sin cifrar. Para las pruebas unitarias sin red,
todos los clientes aceptan un `HTTPTransport` que puedes sustituir.

## Demo

| Inicio de sesión                                              | Notas en Firestore                                    | Cuenta y token                                          |
| ------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------- |
| ![Pantalla de inicio de sesión, claro](docs/images/sign-in-light.png) | ![Lista de notas, claro](docs/images/notes-light.png) | ![Pantalla de cuenta, claro](docs/images/account-light.png) |
| ![Pantalla de inicio de sesión, oscuro](docs/images/sign-in-dark.png) | ![Lista de notas, oscuro](docs/images/notes-dark.png) | ![Pantalla de cuenta, oscuro](docs/images/account-dark.png) |

Las capturas proceden de las pruebas de interfaz de la app de ejemplo en un simulador de iPhone,
ejecutadas con Firebase Local Emulator Suite mediante
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh): la prueba se registra, escribe
tres notas, fija una (las notas fijadas salen primero) y abre la pantalla de cuenta, donde el ID
token aparece solo como `Secret(redacted, … characters)`.

Para probarlo tú mismo, ejecuta `scripts/start-emulators.sh`, abre `FirebaseLab.xcodeproj` en
[`Examples/FirebaseLab`](Examples/FirebaseLab), elige un simulador de iPhone y pulsa **Run**.
[Examples/README.md](Examples/README.md) tiene los detalles, y la herramienta de línea de comandos
`fbcheck` de [`Examples/ConfigCheck`](Examples/ConfigCheck) revisa plists y verifica tokens.

## Documentación

Referencia de la API y artículos:

- [Referencia de la API](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, publicada en GitHub Pages desde `master`)
- Compílala en local en Xcode con **Product › Build Documentation**, o desde la línea de comandos:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Guías

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — añadir el paquete, preparar el proyecto de Firebase, iniciar sesión y guardar un documento
  ([código fuente](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — inicio de sesión con correo, anónimo, Apple y Google, errores, la sesión en el llavero y tokens vigentes
  ([código fuente](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — modelos, consultas, escrituras, transformaciones, lotes y los límites que comprueba el cliente
  ([código fuente](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — las reglas de Firebase, la caché de claves, los claims y el desfase del reloj en un servidor Swift
  ([código fuente](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — Local Emulator Suite, `emulators:exec` y pruebas unitarias con un transport de prueba
  ([código fuente](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).

## Requisitos

| Plataforma   | Versión mínima        |
| ------------ | --------------------- |
| iOS          | 17                    |
| macOS        | 14                    |
| tvOS         | 17                    |
| watchOS      | 10                    |
| visionOS     | 1                     |
| Herramientas | Swift 6.2 · Xcode 26+ |

El paquete usa el framework Security y CryptoKit, por lo que no se compila en Linux. La CI compila
con el Xcode predeterminado de la imagen de runner `macos-26` de GitHub; el paquete se desarrolla
con Xcode 27. Las pruebas con emuladores necesitan la Firebase CLI y Java 21 o posterior.

## Arquitectura

- `Project/`: `FirebaseProject` (ID del proyecto, clave de API, base de datos, emuladores) y
  `GoogleServiceInfo`, que lee y comprueba el plist.
- `Auth/`: `FirebaseAuthClient`, un actor sobre las API REST de Identity Toolkit y Secure Token;
  `AuthSession` y el `SessionStore` donde se guarda (llavero o memoria); credenciales de los
  proveedores.
- `Firestore/`: `FirestoreClient`, un struct `Sendable` sobre la API REST de Firestore;
  `FirestoreValue` con su forma JSON, el codificador y el decodificador `Codable`, rutas,
  consultas y `WriteBatch`. Todas las escrituras pasan por el endpoint `commit`, así que una
  escritura individual y un lote se comportan igual.
- `Tokens/`: el análisis de `JSONWebToken`, `IDTokenClaims` e `IDTokenVerifier` con claves RSA del
  JSON Web Key Set de Google.
- `Transport/`: el protocolo `HTTPTransport` y su implementación con `URLSession`, el único lugar
  que toca la red.
- Los datos que llegan de fuera del proceso tienen límites: cuerpos de respuesta (16 MiB), tokens
  (16 KiB), plists (64 KiB), profundidad de anidamiento, rangos numéricos antes de cualquier
  conversión y direcciones de emulador (solo `host:port`).

Ejecuta las pruebas en local:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Hoja de ruta

- Añadir el paquete al Swift Package Index; `.spi.yml` ya está en el repositorio.
- Transacciones de Firestore (`beginTransaction` y un commit con la transacción).
- Vincular proveedores a un usuario existente y verificación del correo electrónico.
- Una versión de `IDTokenVerifier` para Linux sobre swift-crypto.

Los listeners en tiempo real y la caché sin conexión no están previstos: necesitan la conexión de
streaming gRPC de Firestore, que la API REST no ofrece.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
