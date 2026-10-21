<!-- i18n-source: README.md@00e4a68870ee483107d14ea970068d1fcdd04d3c status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

iOSFirebaseTools 是一个用于 Firebase Authentication 和 Cloud Firestore 的 Swift 包。它通过 `URLSession` 直接调用 Firebase 的 REST API，而不是内嵌 Firebase SDK。它面向 SDK 不适用或根本不存在的场景：体积和内存预算都很紧张的 App Clip 与小组件、watchOS、命令行工具，以及需要校验应用所发送 ID 令牌的 Swift 服务器。它负责用户登录并让令牌保持有效，把 `Codable` 模型映射为 Firestore 文档，可以直接对接 Firebase Local Emulator Suite 运行，并能在服务器上验证 ID 令牌。除 Apple 的 SDK 之外，它没有任何依赖。

## 亮点

- **登录后保持登录状态** — 支持邮箱和密码、匿名、Sign in with Apple 以及 Google；会话保存在钥匙串中，ID 令牌会在过期前刷新，无论有多少并发调用方，都只发出一次请求。
- **用你自己的类型读写 Firestore** — 读取、查询、写入、批量写入 `Codable` 模型，并在事务中执行读写；`Date` 会转换为时间戳，服务器时间戳和自增只需一个参数。
- **抛出错误，而不是崩溃** — 超出 `Int64` 范围的整数、`Int` 字段中的 NaN、10000 年的日期或 20 MB 的响应都会抛出带类型的错误；路径、字段名和限制会在发出请求之前按 Firebase 的规则检查。
- **在你的服务器上校验 ID 令牌** — `IDTokenVerifier` 使用 Google 公布的密钥，按 Firebase 的规则校验 RS256 令牌；Admin SDK 为其他语言提供了这一能力，但没有提供 Swift 版本。
- **日志中没有机密** — 令牌、邮箱地址、请求体、查询值、形似 ID 的路径片段以及服务器返回的消息，都不会出现在 `print`、`dump`、日志和调试器显示的内容中；参见[日志会显示什么](#日志会显示什么)。
- **端到端测试** — 142 个 Swift Testing 测试，其中 10 个针对启用 Security Rules 的 Authentication 和 Firestore 模拟器运行，另有 5 个在模拟器上运行的示例应用 UI 测试。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. 导入模块**

```swift
import iOSFirebaseTools
```

**3. 开始使用**

把项目的 `GoogleService-Info.plist` 添加到应用 target，启用 **Anonymous** 登录，并在 [Firebase console](https://console.firebase.google.com) 中创建 Cloud Firestore 数据库，同时配置允许用户写入自己笔记的 [Security Rules](Emulators/firestore.rules)。然后把新建 iOS 应用的 `ContentView.swift` 替换为：

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

运行应用并点按按钮：文本会显示 `Saved notes/…`，该笔记会出现在控制台的 **Firestore Database** 下。还没有 Firebase 项目？同样的代码也可以在你的 Mac 上对接模拟器运行；参见[使用模拟器测试](#使用模拟器测试)。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

## 使用方法

下面的示例复制自 [`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift)，示例应用和软件包的测试都会编译这个文件，模拟器测试则会运行它。

### 一次性配置客户端

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

### 登录

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

`auth.idToken()` 返回一个至少还有五分钟有效期的令牌，必要时会先刷新。Sign in with Apple 使用 `auth.signIn(with: .apple(idToken:rawNonce:))`，nonce 由 `AppleSignInNonce` 生成；完整流程见 [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin) 指南。

### 读取和写入文档

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

### 原子写入

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### 在事务中读取和写入

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

如果在读取和提交之间有其他写入修改了这条笔记，Firestore 会中止这次提交，闭包会再次运行，默认最多五次。

### 在服务器上校验令牌

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### 使用模拟器测试

用 [Firebase CLI](https://firebase.google.com/docs/cli) 启动 Authentication 和 Firestore 模拟器（`firebase emulators:start --only auth,firestore --project demo-notes`；需要 Java 21 或更高版本），然后让客户端指向它们。以 `demo-` 开头的项目 ID 不需要 Firebase 账号。

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

由于模拟器使用明文 HTTP，iOS 应用的 Info.plist 中还需要在 `NSAppTransportSecurity` 下设置 `NSAllowsLocalNetworking`。如果单元测试完全不走网络，每个客户端都接受一个可替换的 `HTTPTransport`。

## 演示

| 登录                                                   | Firestore 中的笔记                             | 账号与令牌                                        |
| ------------------------------------------------------ | ---------------------------------------------- | --------------------------------------------------- |
| ![登录界面，浅色](docs/images/sign-in-light.png)       | ![笔记列表，浅色](docs/images/notes-light.png) | ![账号界面，浅色](docs/images/account-light.png)    |
| ![登录界面，深色](docs/images/sign-in-dark.png)        | ![笔记列表，深色](docs/images/notes-dark.png)  | ![账号界面，深色](docs/images/account-dark.png)     |

这些截图来自示例应用在 iPhone 模拟器上的 UI 测试，由 [`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh) 对 Firebase Local Emulator Suite 运行：测试会注册账号、写入三条笔记、置顶其中一条（置顶的笔记排在最前），然后打开账号界面，其中 ID 令牌只显示为 `Secret(redacted, … characters)`。

想自己试一试，请运行 `scripts/start-emulators.sh`，在 [`Examples/FirebaseLab`](Examples/FirebaseLab) 中打开 `FirebaseLab.xcodeproj`，选择一个 iPhone 模拟器并点击 **Run**。详细说明见 [Examples/README.md](Examples/README.md)；[`Examples/ConfigCheck`](Examples/ConfigCheck) 中的命令行工具 `fbcheck` 可以检查 plist 并验证令牌。

## 日志会显示什么

软件包中每个可能包含令牌、密码或个人数据的值，打印时都是脱敏后的形式。代码无法完全理解的内容会被隐藏：

| 值                                     | 显示                                                   | 绝不显示                                               |
| -------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------ |
| `Secret`                               | 它的长度                                               | 值本身                                                 |
| `AuthSession`                          | 用户 ID 的开头、是否匿名、过期时间                     | 令牌、邮箱地址                                         |
| `HTTPRequest`, `HTTPResponse`          | 方法、主机、路径、查询参数名、允许列表中的请求头、状态 | 请求体、用户信息、片段、查询参数值、形似 ID 的路径片段 |
| `AuthError`, `FirestoreError`          | 错误码和 HTTP 状态                                     | 服务器返回的消息（请在代码中读取 `message`）           |
| `FirebaseProject`, `GoogleServiceInfo` | 项目 ID、数据库、bundle ID                             | API 密钥                                               |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

名称会在经过百分号解码、NFKC 规范化和大小写折叠之后再比较；如果名称此时仍不是纯 ASCII，例如 `şifre`，或包含西里尔字母的 `password`，则按机密处理。请求体绝不会被解析或显示。`RedactionPolicy` 列出了其值可以出现在你自己日志中的请求头和查询参数。

这只是一道安全网，而不是保证：它无法对你自己写出的文本脱敏，而且 URL 路径中较短的机密可能看起来就像一个普通单词。请从一开始就不要把机密放进日志和 URL。完整的规则与限制见 [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction) 这篇文章。

## 文档

API 参考文档与文章：

- [API 参考](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)（DocC，从 `master` 分支发布到 GitHub Pages）
- 在 Xcode 中通过 **Product › Build Documentation** 在本地构建，或使用命令行：

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## 指南

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted) — 添加软件包、准备 Firebase 项目、登录并保存一个文档（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)）。
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin) — 邮箱、匿名、Apple 和 Google 登录，错误处理，钥匙串中的会话以及保持令牌有效（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)）。
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore) — 模型、查询、写入、转换、批量写入、事务，以及客户端会检查的限制（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)）。
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens) — 在 Swift 服务器上应用 Firebase 的规则、密钥缓存、claims 和时钟偏差（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)）。
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators) — Local Emulator Suite、`emulators:exec`，以及使用测试用 transport 的单元测试（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)）。
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction) — 请求、会话和错误在日志中显示什么、允许列表，以及哪些内容不会被发现（[源文件](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)）。

## 系统要求

| 平台       | 最低版本                  |
| -------- | --------------------- |
| iOS      | 17                    |
| macOS    | 14                    |
| tvOS     | 17                    |
| watchOS  | 10                    |
| visionOS | 1                     |
| 工具链      | Swift 6.2 · Xcode 26+ |

该软件包使用 Security 框架和 CryptoKit，因此无法在 Linux 上构建。CI 使用 GitHub `macos-26` runner 镜像中的默认 Xcode 构建；软件包本身使用 Xcode 27 开发。模拟器测试需要 Firebase CLI 和 Java 21 或更高版本。

## 架构

- `Project/`：`FirebaseProject`（项目 ID、API 密钥、数据库、模拟器）和用于读取并检查 plist 的 `GoogleServiceInfo`。
- `Auth/`：`FirebaseAuthClient`，一个基于 Identity Toolkit 和 Secure Token REST API 的 actor；`AuthSession` 以及保存它的 `SessionStore`（钥匙串或内存）；各登录提供方的凭据。
- `Firestore/`：`FirestoreClient`，一个基于 Firestore REST API 的 `Sendable` 结构体；`FirestoreValue` 及其 JSON 形式、`Codable` 编码器和解码器、路径、查询，以及 `WriteBatch` 和 `FirestoreTransaction`。所有写入都经过 `commit` 端点，因此单次写入、批量写入和事务的行为一致。
- `Tokens/`：`JSONWebToken` 解析、`IDTokenClaims`，以及使用 Google JSON Web Key Set 中 RSA 密钥的 `IDTokenVerifier`。
- `Transport/`：`HTTPTransport` 协议及其 `URLSession` 实现，也是唯一接触网络的地方。
- `Support/`：`Secret`、`ValidationError`，以及所有文本形式共用的脱敏规则。
- 来自进程外部的输入都有上限：响应体（16 MiB）、令牌（16 KiB）、plist（64 KiB）、嵌套深度、转换前的数值范围，以及模拟器地址（仅限 `host:port`）。

在本地运行测试：

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## 路线图

- 把软件包加入 Swift Package Index；仓库中已经有 `.spi.yml`。
- 把登录提供方关联到已有用户，以及邮箱验证。
- 基于 swift-crypto 的 `IDTokenVerifier` Linux 版本。

实时监听和离线缓存不在计划之内：它们需要 Firestore 的 gRPC 流式连接，而 REST API 并不提供。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
