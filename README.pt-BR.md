<!-- i18n-source: README.md@e58ec5fc64f013f130f40242c1352ea03fa05302 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Versão mais recente: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

O iOSFirebaseTools é um pacote Swift para Firebase Authentication e Cloud Firestore que usa as APIs
REST do Firebase com `URLSession` em vez de embutir o SDK do Firebase. Ele serve para o código em
que o SDK não se encaixa ou não existe: App Clips e widgets com orçamentos apertados de tamanho e
memória, watchOS, ferramentas de linha de comando e servidores Swift que precisam verificar o ID
token que um app envia. Ele autentica usuários e mantém o token deles atualizado, mapeia modelos
`Codable` para documentos do Firestore, roda com o Firebase Local Emulator Suite e verifica ID
tokens em um servidor. Não tem dependências além do SDK da Apple.

## Destaques

- **Login que continua ativo** — e-mail e senha, anônimo, Sign in with Apple e Google; a sessão fica
  no Keychain e o ID token é renovado antes de expirar, com uma única requisição, não importa
  quantos chamadores simultâneos existam.
- **Firestore com os seus próprios tipos** — leia, consulte, grave e agrupe em lote modelos
  `Codable`; `Date` vira um timestamp, e os timestamps do servidor e os incrementos são um único
  argumento.
- **Erros em vez de falhas** — um inteiro que estoura `Int64`, um NaN em um campo `Int`, uma data no
  ano 10000 ou uma resposta de 20 MB lançam um erro tipado; caminhos, nomes de campos e limites
  são verificados segundo as regras do Firebase antes de qualquer requisição ser enviada.
- **ID tokens verificados no seu servidor** — `IDTokenVerifier` aplica as regras do Firebase para
  tokens RS256 com as chaves publicadas pelo Google, o que os Admin SDKs fazem para outras
  linguagens, mas não para Swift.
- **Tokens nunca são impressos** — sessões e tokens mostram apenas o tamanho em `print`, `dump`,
  logs e no depurador.
- **Testado de ponta a ponta** — 105 testes com Swift Testing, 9 deles contra os emuladores de
  Authentication e Firestore com Security Rules, e cinco testes de interface do app de exemplo em
  um simulador.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Importe o módulo**

```swift
import iOSFirebaseTools
```

**3. Use**

Adicione o `GoogleService-Info.plist` do seu projeto ao target do app, ative o login **Anonymous** e
crie um banco de dados do Cloud Firestore no [Firebase console](https://console.firebase.google.com),
com [Security Rules](Emulators/firestore.rules) que permitam aos usuários gravar as próprias notas.
Depois, substitua o `ContentView.swift` de um app iOS novo por:

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

Execute o app e toque no botão: o texto mostra `Saved notes/…` e a nota aparece em
**Firestore Database** no console. Ainda não tem um projeto do Firebase? O mesmo código roda contra
os emuladores no seu Mac; veja [Testando com os emuladores](#testando-com-os-emuladores).

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

Os exemplos abaixo foram copiados de
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift),
que o app de exemplo e os testes do pacote compilam e que os testes com emuladores executam.

### Configure os clientes uma única vez

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

### Fazer login

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

`auth.idToken()` retorna um token válido por pelo menos mais cinco minutos, renovando-o se
necessário. O Sign in with Apple é `auth.signIn(with: .apple(idToken:rawNonce:))`, com
`AppleSignInNonce` para o nonce; o guia
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
tem o fluxo completo.

### Ler e gravar documentos

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

### Gravar de forma atômica

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Verificar o token no seu servidor

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Testando com os emuladores

Inicie os emuladores de Authentication e Firestore com a [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes`; Java 21 ou posterior) e
aponte os clientes para eles. Um ID de projeto que começa com `demo-` não precisa de conta no
Firebase.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Um app iOS também precisa de `NSAllowsLocalNetworking` em `NSAppTransportSecurity` no Info.plist,
porque os emuladores servem HTTP sem criptografia. Para testes unitários sem rede, todo cliente
aceita um `HTTPTransport` que você pode substituir.

## Demonstração

| Login                                                      | Notas no Firestore                                  | Conta e token                                             |
| ---------------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------- |
| ![Tela de login, claro](docs/images/sign-in-light.png)     | ![Lista de notas, claro](docs/images/notes-light.png) | ![Tela da conta, claro](docs/images/account-light.png)  |
| ![Tela de login, escuro](docs/images/sign-in-dark.png)     | ![Lista de notas, escuro](docs/images/notes-dark.png) | ![Tela da conta, escuro](docs/images/account-dark.png)  |

As capturas de tela vêm dos testes de interface do app de exemplo em um simulador de iPhone,
executados contra o Firebase Local Emulator Suite pelo script
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh): o teste cria uma conta, grava
três notas, fixa uma (as notas fixadas vêm primeiro) e abre a tela da conta, onde o ID token
aparece apenas como `Secret(redacted, … characters)`.

Para experimentar por conta própria, execute `scripts/start-emulators.sh`, abra o
`FirebaseLab.xcodeproj` em [`Examples/FirebaseLab`](Examples/FirebaseLab), escolha um simulador de
iPhone e pressione **Run**. O [Examples/README.md](Examples/README.md) traz os detalhes, e a
ferramenta de linha de comando `fbcheck`, em [`Examples/ConfigCheck`](Examples/ConfigCheck), verifica
plists e valida tokens.

## Documentação

Referência da API e artigos:

- [Referência da API](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, publicada no GitHub Pages a partir de `master`)
- Gere-a localmente no Xcode com **Product › Build Documentation**, ou pela linha de comando:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Guias

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — adicionar o pacote, preparar o projeto do Firebase, fazer login e salvar um documento
  ([código-fonte](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — login por e-mail, anônimo, Apple e Google, erros, a sessão no Keychain e tokens atualizados
  ([código-fonte](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — modelos, consultas, gravações, transformações, lotes e os limites que o cliente verifica
  ([código-fonte](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — as regras do Firebase, cache de chaves, claims e diferença de relógio em um servidor Swift
  ([código-fonte](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — o Local Emulator Suite, `emulators:exec` e testes unitários com um transport de teste
  ([código-fonte](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).

## Requisitos

| Plataforma  | Versão mínima         |
| ----------- | --------------------- |
| iOS         | 17                    |
| macOS       | 14                    |
| tvOS        | 17                    |
| watchOS     | 10                    |
| visionOS    | 1                     |
| Ferramentas | Swift 6.2 · Xcode 26+ |

O pacote usa o framework Security e o CryptoKit, por isso não compila no Linux. A CI compila com o
Xcode padrão da imagem de runner `macos-26` do GitHub; o pacote é desenvolvido com o Xcode 27. Os
testes com emuladores precisam da Firebase CLI e do Java 21 ou posterior.

## Arquitetura

- `Project/`: `FirebaseProject` (ID do projeto, chave de API, banco de dados, emuladores) e
  `GoogleServiceInfo`, que lê e verifica o plist.
- `Auth/`: `FirebaseAuthClient`, um actor sobre as APIs REST do Identity Toolkit e do Secure Token;
  `AuthSession` e o `SessionStore` em que ela é salva (Keychain ou memória); credenciais dos
  provedores.
- `Firestore/`: `FirestoreClient`, um struct `Sendable` sobre a API REST do Firestore;
  `FirestoreValue` com sua forma em JSON, o encoder e o decoder `Codable`, caminhos, consultas e
  `WriteBatch`. Todas as gravações passam pelo endpoint `commit`, então uma gravação isolada e um
  lote se comportam da mesma forma.
- `Tokens/`: a análise de `JSONWebToken`, `IDTokenClaims` e `IDTokenVerifier` com chaves RSA do
  JSON Web Key Set do Google.
- `Transport/`: o protocolo `HTTPTransport` e sua implementação com `URLSession`, o único lugar
  que acessa a rede.
- Toda entrada vinda de fora do processo tem limite: corpos de resposta (16 MiB), tokens (16 KiB),
  plists (64 KiB), profundidade de aninhamento, faixas de números antes de qualquer conversão e
  endereços de emulador (somente `host:port`).

Execute os testes localmente:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Roteiro

- Adicionar o pacote ao Swift Package Index; o `.spi.yml` já está no repositório.
- Transações do Firestore (`beginTransaction` e um commit com a transação).
- Vincular provedores a um usuário existente e verificação de e-mail.
- Uma versão do `IDTokenVerifier` para Linux sobre o swift-crypto.

Listeners em tempo real e o cache offline não estão planejados: eles precisam da conexão de
streaming gRPC do Firestore, que a API REST não oferece.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
