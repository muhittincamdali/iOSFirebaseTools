<!-- i18n-source: README.md@9444151db75676a7995e80b9caace05a8fecbc34 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

iOSFirebaseTools — это Swift-пакет для Firebase Authentication и Cloud Firestore, который обращается
к REST API Firebase через `URLSession` вместо встраивания Firebase SDK. Он нужен там, где SDK не
подходит или отсутствует: App Clip и виджеты с жёсткими лимитами на размер и память, watchOS,
утилиты командной строки и Swift-серверы, которым нужно проверять ID-токен, присланный приложением.
Пакет выполняет вход пользователей и поддерживает их токен актуальным, сопоставляет модели
`Codable` с документами Firestore, работает с Firebase Local Emulator Suite и проверяет ID-токены на
сервере. Зависимостей, кроме SDK от Apple, у него нет.

## Основные возможности

- **Вход, который сохраняется** — e-mail и пароль, анонимный вход, Sign in with Apple и Google;
  сессия хранится в связке ключей, а ID-токен обновляется до истечения срока, причём одним запросом
  при любом числе одновременных вызовов.
- **Firestore со своими типами** — чтение, запросы, запись, пакетная запись и транзакции для моделей
  `Codable`; `Date` превращается в метку времени, а серверные метки времени и приращения задаются
  одним аргументом.
- **Ошибки вместо падений** — целое число, переполняющее `Int64`, NaN в поле `Int`, дата в 10000 году
  или ответ в 20 МБ приводят к типизированной ошибке; пути, имена полей и лимиты проверяются по
  правилам Firebase до отправки запроса.
- **Проверка ID-токенов на вашем сервере** — `IDTokenVerifier` применяет правила Firebase для
  RS256-токенов с опубликованными Google ключами; Admin SDK делают это для других языков, но не для
  Swift.
- **Логи без секретов** — токены, адреса e-mail, тела запросов, значения параметров запросов,
  сегменты пути, похожие на идентификаторы, и сообщения сервера не попадают в то, что показывают
  `print`, `dump`, логи и отладчик; см. [Что показывают логи](#что-показывают-логи).
- **Сквозное тестирование** — 142 тестов на Swift Testing, 10 из них идут против эмуляторов
  Authentication и Firestore с Security Rules, плюс пять UI-тестов примера приложения на симуляторе.

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. Импортируйте модуль**

```swift
import iOSFirebaseTools
```

**3. Используйте**

Добавьте `GoogleService-Info.plist` вашего проекта в таргет приложения, включите вход **Anonymous**
и создайте базу Cloud Firestore в [Firebase console](https://console.firebase.google.com) с
[Security Rules](Emulators/firestore.rules), позволяющими пользователям записывать собственные
заметки. Затем замените `ContentView.swift` в новом iOS-приложении на:

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

Запустите приложение и нажмите кнопку: в тексте появится `Saved notes/…`, а заметка отобразится в
консоли в разделе **Firestore Database**. Ещё нет проекта Firebase? Тот же код работает с
эмуляторами на вашем Mac; см. [Тестирование с эмуляторами](#тестирование-с-эмуляторами).

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

## Использование

Примеры ниже скопированы из
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift);
этот файл компилируют пример приложения и тесты пакета, а тесты с эмуляторами запускают.

### Настройте клиенты один раз

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

### Вход

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

`auth.idToken()` возвращает токен, который будет действителен ещё как минимум пять минут, и при
необходимости обновляет его. Sign in with Apple — это `auth.signIn(with: .apple(idToken:rawNonce:))`,
а для nonce есть `AppleSignInNonce`; полный сценарий описан в руководстве
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin).

### Чтение и запись документов

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

### Атомарная запись

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### Чтение и запись в транзакции

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

Если между чтением и фиксацией заметку изменит другая запись, Firestore отменяет commit, и замыкание
выполняется снова — по умолчанию до пяти раз.

### Проверка токена на вашем сервере

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### Тестирование с эмуляторами

Запустите эмуляторы Authentication и Firestore через [Firebase CLI](https://firebase.google.com/docs/cli)
(`firebase emulators:start --only auth,firestore --project demo-notes`; нужна Java 21 или новее) и
направьте клиенты на них. Идентификатору проекта, который начинается с `demo-`, аккаунт Firebase не
нужен.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

Приложению для iOS также нужен ключ `NSAllowsLocalNetworking` в `NSAppTransportSecurity` в его
Info.plist, потому что эмуляторы отвечают по обычному HTTP. Для модульных тестов без сети любой
клиент принимает `HTTPTransport`, который можно заменить.

## Демо

| Вход                                                        | Заметки в Firestore                                  | Аккаунт и токен                                             |
| ----------------------------------------------------------- | ---------------------------------------------------- | ----------------------------------------------------------- |
| ![Экран входа, светлая тема](docs/images/sign-in-light.png) | ![Список заметок, светлая тема](docs/images/notes-light.png) | ![Экран аккаунта, светлая тема](docs/images/account-light.png) |
| ![Экран входа, тёмная тема](docs/images/sign-in-dark.png)   | ![Список заметок, тёмная тема](docs/images/notes-dark.png)   | ![Экран аккаунта, тёмная тема](docs/images/account-dark.png)   |

Скриншоты сделаны в UI-тестах примера приложения на симуляторе iPhone; скрипт
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) запускает их против Firebase
Local Emulator Suite: тест регистрируется, записывает три заметки, закрепляет одну (закреплённые
заметки идут первыми) и открывает экран аккаунта, где ID-токен виден только как
`Secret(redacted, … characters)`.

Чтобы попробовать самостоятельно, запустите `scripts/start-emulators.sh`, откройте
`FirebaseLab.xcodeproj` в [`Examples/FirebaseLab`](Examples/FirebaseLab), выберите симулятор iPhone и
нажмите **Run**. Подробности — в [Examples/README.md](Examples/README.md), а утилита командной строки
`fbcheck` в [`Examples/ConfigCheck`](Examples/ConfigCheck) проверяет plist-файлы и токены.

## Что показывают логи

Каждое значение в пакете, которое может содержать токен, пароль или персональные данные, выводится в
скрытом виде. То, что код понимает не полностью, скрывается:

| Значение                               | Показывается                                                                         | Никогда не показывается                                                                                         |
| -------------------------------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| `Secret`                               | его длина                                                                            | значение                                                                                                        |
| `AuthSession`                          | начало ID пользователя, анонимный он или нет, срок действия                          | токены, адрес e-mail                                                                                            |
| `HTTPRequest`, `HTTPResponse`          | метод, хост, путь, имена параметров запроса, заголовки из списка разрешённых, статус | тела, сведения о пользователе, фрагменты, значения параметров запроса, сегменты пути, похожие на идентификаторы |
| `AuthError`, `FirestoreError`          | код и HTTP-статус                                                                    | сообщение сервера (читайте `message` в коде)                                                                    |
| `FirebaseProject`, `GoogleServiceInfo` | ID проекта, база данных, bundle ID                                                   | ключ API                                                                                                        |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

Имена сравниваются после раскодирования процентных последовательностей, нормализации NFKC и свёртки
регистра, а имя, которое всё равно не состоит из обычных ASCII-символов, например `şifre` или
`password` с кириллической буквой, считается секретным. Тела никогда не разбираются и не
показываются. `RedactionPolicy` перечисляет заголовки и параметры запроса, значения которых могут
показывать ваши собственные логи.

Это страховочная сетка, а не гарантия: она не может скрыть текст, который вы пишете сами, а короткий
секрет в пути URL может выглядеть как обычное слово. Не допускайте секреты в логи и URL с самого
начала. Полные правила и ограничения описаны в статье
[Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction).

## Документация

Справочник API и статьи:

- [Справочник API](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, публикуется на GitHub Pages из ветки `master`)
- Локально документацию можно собрать в Xcode через **Product › Build Documentation** или из
  командной строки:

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## Руководства

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — подключение пакета, подготовка проекта Firebase, вход и сохранение документа
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — вход по e-mail, анонимный, через Apple и Google, ошибки, сессия в связке ключей и актуальные токены
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — модели, запросы, записи, трансформации, пакеты, транзакции и лимиты, которые проверяет клиент
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — правила Firebase, кеширование ключей, claims и расхождение часов на Swift-сервере
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — Local Emulator Suite, `emulators:exec` и модульные тесты с тестовым transport
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  — что запросы, сессии и ошибки показывают в логах, список разрешённого и что остаётся необнаруженным
  ([исходник](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)).

## Требования

| Платформа   | Минимальная версия    |
| ----------- | --------------------- |
| iOS         | 17                    |
| macOS       | 14                    |
| tvOS        | 17                    |
| watchOS     | 10                    |
| visionOS    | 1                     |
| Инструменты | Swift 6.2 · Xcode 26+ |

Пакет использует фреймворк Security и CryptoKit, поэтому не собирается под Linux. CI собирает
пакет с Xcode по умолчанию из образа раннера `macos-26` на GitHub; разрабатывается пакет в
Xcode 27. Для тестов с эмуляторами нужны Firebase CLI и Java 21 или новее.

## Архитектура

- `Project/`: `FirebaseProject` (идентификатор проекта, ключ API, база данных, эмуляторы) и
  `GoogleServiceInfo`, который читает и проверяет plist.
- `Auth/`: `FirebaseAuthClient` — actor поверх REST API Identity Toolkit и Secure Token;
  `AuthSession` и `SessionStore`, в котором она хранится (связка ключей или память); учётные данные
  провайдеров.
- `Firestore/`: `FirestoreClient` — `Sendable`-структура поверх REST API Firestore; `FirestoreValue`
  с его JSON-представлением, кодировщик и декодировщик `Codable`, пути, запросы, `WriteBatch` и
  `FirestoreTransaction`. Все записи идут через endpoint `commit`, поэтому одиночная запись, пакет и
  транзакция ведут себя одинаково.
- `Tokens/`: разбор `JSONWebToken`, `IDTokenClaims` и `IDTokenVerifier` с RSA-ключами из JSON Web
  Key Set Google.
- `Transport/`: протокол `HTTPTransport` и его реализация на `URLSession` — единственное место,
  которое обращается к сети.
- `Support/`: `Secret`, `ValidationError` и правила скрытия данных, общие для всех текстовых
  представлений.
- Входные данные извне процесса ограничены: тела ответов (16 MiB), токены (16 KiB), plist-файлы
  (64 KiB), глубина вложенности, диапазоны чисел до любого преобразования и адреса эмуляторов (только
  `host:port`).

Запустите тесты локально:

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## План развития

- Добавить пакет в Swift Package Index; файл `.spi.yml` уже есть в репозитории.
- Привязка провайдеров к существующему пользователю и подтверждение e-mail.
- Сборка `IDTokenVerifier` под Linux на swift-crypto.

Слушатели в реальном времени и офлайн-кеш не планируются: для них нужно потоковое gRPC-соединение
Firestore, которого REST API не предоставляет.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
