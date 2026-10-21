<!-- i18n-source: README.md@9444151db75676a7995e80b9caace05a8fecbc34 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/banner-light.svg" alt="iOSFirebaseTools: Firebase Auth and Firestore for Swift over REST: Codable models, emulator tests and server-side token checks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOSFirebaseTools/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSFirebaseTools/master/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

iOSFirebaseTools는 Firebase Authentication과 Cloud Firestore를 위한 Swift 패키지입니다. Firebase
SDK를 포함하는 대신 `URLSession`으로 Firebase의 REST API와 직접 통신합니다. SDK가 맞지 않거나
아예 없는 환경을 위한 것입니다. 크기와 메모리 예산이 빠듯한 App Clip과 위젯, watchOS, 명령줄
도구, 앱이 보낸 ID 토큰을 확인해야 하는 Swift 서버가 그런 예입니다. 사용자를 로그인시키고
토큰을 최신 상태로 유지하며, `Codable` 모델을 Firestore 문서에 매핑하고, Firebase Local Emulator
Suite를 대상으로 실행할 수 있으며, 서버에서 ID 토큰을 검증합니다. Apple SDK 외에는 의존성이
없습니다.

## 주요 기능

- **로그인 상태가 유지되는 인증** — 이메일과 비밀번호, 익명, Sign in with Apple, Google을
  지원합니다. 세션은 키체인에 저장되고 ID 토큰은 만료되기 전에 갱신되며, 동시에 호출하는
  곳이 몇 개든 요청은 한 번만 보냅니다.
- **직접 만든 타입으로 쓰는 Firestore** — `Codable` 모델을 읽고, 쿼리하고, 쓰고, 일괄 처리하고, 트랜잭션 안에서 실행할 수
  있습니다. `Date`는 타임스탬프가 되며, 서버 타임스탬프와 증가 연산은 인자 하나로 지정합니다.
- **충돌 대신 오류** — `Int64`를 넘는 정수, `Int` 필드의 NaN, 10000년의 날짜, 20 MB 응답은 타입이
  있는 오류를 던집니다. 경로, 필드 이름, 한도는 요청을 보내기 전에 Firebase의 규칙에 따라
  검사합니다.
- **서버에서 ID 토큰 확인** — `IDTokenVerifier`는 Google이 공개한 키로 RS256 토큰에 Firebase의
  규칙을 적용합니다. Admin SDK는 다른 언어에는 이 기능을 제공하지만 Swift에는 제공하지 않습니다.
- **비밀이 없는 로그** — 토큰, 이메일 주소, 요청 본문, 쿼리 값, ID처럼 보이는 경로 세그먼트, 서버의 메시지는 `print`,
  `dump`, 로그, 디버거가 보여 주는 내용에서 제외됩니다. [로그에 표시되는 내용](#로그에-표시되는-내용)을 참고하세요.
- **엔드 투 엔드 테스트** — Swift Testing 테스트 142개 중 10개는 Security Rules가 적용된
  Authentication 및 Firestore 에뮬레이터를 대상으로 실행되며, 예제 앱의 UI 테스트 5개가
  시뮬레이터에서 실행됩니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

**2. 모듈 가져오기**

```swift
import iOSFirebaseTools
```

**3. 사용하기**

프로젝트의 `GoogleService-Info.plist`를 앱 타깃에 추가하고, **Anonymous** 로그인을 활성화한 다음
[Firebase console](https://console.firebase.google.com)에서 Cloud Firestore 데이터베이스를 만드세요.
사용자가 자신의 노트를 쓸 수 있도록 하는 [Security Rules](Emulators/firestore.rules)도 설정합니다.
그런 다음 새 iOS 앱의 `ContentView.swift`를 아래 코드로 바꾸세요.

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

앱을 실행하고 버튼을 누르면 텍스트에 `Saved notes/…`가 표시되고, 노트가 콘솔의
**Firestore Database**에 나타납니다. 아직 Firebase 프로젝트가 없나요? 같은 코드를 Mac의
에뮬레이터를 대상으로 실행할 수 있습니다. [에뮬레이터로 테스트하기](#에뮬레이터로-테스트하기)를
참고하세요.

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOSFirebaseTools.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

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

## 사용법

아래 예제는
[`Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift`](Examples/FirebaseLab/FirebaseLab/ReadmeSamples.swift)
에서 가져온 것입니다. 이 파일은 예제 앱과 패키지 테스트가 컴파일하고, 에뮬레이터 테스트가
실행합니다.

### 클라이언트를 한 번만 설정하기

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

### 로그인

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

`auth.idToken()`은 앞으로 최소 5분 동안 유효한 토큰을 반환하며, 필요하면 먼저 갱신합니다.
Sign in with Apple은 `auth.signIn(with: .apple(idToken:rawNonce:))`로 처리하고, nonce에는
`AppleSignInNonce`를 사용합니다. 전체 흐름은
[Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
가이드를 참고하세요.

### 문서 읽기와 쓰기

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

### 원자적으로 쓰기

```swift
func moveNote(from oldPath: String, to newPath: String, in firestore: FirestoreClient) async throws {
    guard let note = try await firestore.document(oldPath, as: Note.self) else { return }
    var batch = WriteBatch() // both writes happen, or neither
    try batch.create(note.data, at: newPath)
    try batch.delete(oldPath)
    try await firestore.commit(batch)
}
```

### 트랜잭션으로 읽고 쓰기

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

읽기와 커밋 사이에 다른 쓰기가 그 노트를 바꾸면 Firestore는 커밋을 중단하고 클로저가 다시 실행되며, 기본값은 최대 다섯 번입니다.

### 서버에서 토큰 확인하기

```swift
func userID(fromAuthorizationHeader header: String, verifier: IDTokenVerifier) async throws -> String {
    // let verifier = try IDTokenVerifier(projectID: "my-app-1a2b3"), created once
    guard header.hasPrefix("Bearer ") else { throw TokenError.malformed("no bearer token") }
    let claims = try await verifier.verify(String(header.dropFirst("Bearer ".count)))
    return claims.subject
}
```

### 에뮬레이터로 테스트하기

[Firebase CLI](https://firebase.google.com/docs/cli)로 Authentication과 Firestore 에뮬레이터를
시작하고(`firebase emulators:start --only auth,firestore --project demo-notes`, Java 21 이상 필요),
클라이언트가 이를 가리키도록 설정하세요. `demo-`로 시작하는 프로젝트 ID에는 Firebase 계정이
필요하지 않습니다.

```swift
func makeEmulatorClients() throws -> (FirebaseAuthClient, FirestoreClient) {
    // `firebase emulators:start --only auth,firestore --project demo-notes`
    let project = try FirebaseProject(projectID: "demo-notes", apiKey: "any-key")
        .usingEmulators(auth: "127.0.0.1:9099", firestore: "127.0.0.1:8080")
    let auth = FirebaseAuthClient(project: project)
    return (auth, FirestoreClient(project: project, credentials: .user(auth)))
}
```

에뮬레이터는 일반 HTTP로 응답하므로, iOS 앱의 Info.plist에는 `NSAppTransportSecurity` 아래에
`NSAllowsLocalNetworking`도 필요합니다. 네트워크를 쓰지 않는 단위 테스트에서는 모든 클라이언트가
교체할 수 있는 `HTTPTransport`를 받습니다.

## 데모

| 로그인                                                  | Firestore의 노트                                    | 계정과 토큰                                            |
| ------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| ![로그인 화면, 라이트](docs/images/sign-in-light.png)   | ![노트 목록, 라이트](docs/images/notes-light.png)   | ![계정 화면, 라이트](docs/images/account-light.png)     |
| ![로그인 화면, 다크](docs/images/sign-in-dark.png)      | ![노트 목록, 다크](docs/images/notes-dark.png)      | ![계정 화면, 다크](docs/images/account-dark.png)        |

스크린샷은 예제 앱의 UI 테스트를 iPhone 시뮬레이터에서 실행해 얻은 것입니다.
[`scripts/capture-screenshots.sh`](scripts/capture-screenshots.sh)가 Firebase Local Emulator Suite를
대상으로 테스트를 실행합니다. 테스트는 가입하고, 노트 세 개를 쓰고, 하나를 고정한 다음(고정한
노트가 먼저 나옵니다) 계정 화면을 엽니다. 이 화면에서 ID 토큰은 `Secret(redacted, … characters)`로만
표시됩니다.

직접 해 보려면 `scripts/start-emulators.sh`를 실행하고, [`Examples/FirebaseLab`](Examples/FirebaseLab)의
`FirebaseLab.xcodeproj`를 열어 iPhone 시뮬레이터를 선택한 뒤 **Run**을 누르세요. 자세한 내용은
[Examples/README.md](Examples/README.md)에 있으며, [`Examples/ConfigCheck`](Examples/ConfigCheck)의
명령줄 도구 `fbcheck`는 plist를 검사하고 토큰을 검증합니다.

## 로그에 표시되는 내용

이 패키지에서 토큰, 비밀번호 또는 개인 데이터를 담을 수 있는 모든 값은 가려진 형태로 출력됩니다. 코드가 완전히 이해하지 못하는 내용은 숨겨집니다.

| 값                                     | 표시되는 것                                                  | 절대 표시되지 않는 것                                               |
| -------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------- |
| `Secret`                               | 길이                                                         | 값                                                                  |
| `AuthSession`                          | 사용자 ID의 앞부분, 익명 여부, 만료 시각                     | 토큰, 이메일 주소                                                   |
| `HTTPRequest`, `HTTPResponse`          | 메서드, 호스트, 경로, 쿼리 이름, 허용 목록에 있는 헤더, 상태 | 본문, 사용자 정보, 프래그먼트, 쿼리 값, ID처럼 보이는 경로 세그먼트 |
| `AuthError`, `FirestoreError`          | 코드와 HTTP 상태                                             | 서버의 메시지(코드에서 `message`를 읽으세요)                        |
| `FirebaseProject`, `GoogleServiceInfo` | 프로젝트 ID, 데이터베이스, 번들 ID                           | API 키                                                              |

```text
HTTPRequest(POST https://securetoken.googleapis.com/v1/token?key=<redacted>,
  headers: [authorization: <redacted>, content-type: application/x-www-form-urlencoded],
  body: [body omitted: 48 bytes, application/x-www-form-urlencoded])
```

이름은 퍼센트 디코딩, NFKC 정규화, 대소문자 접기를 거친 뒤 비교되며, 그래도 일반 ASCII가 아닌 이름(예: `şifre` 또는 키릴 문자가
섞인 `password`)은 비밀로 취급됩니다. 본문은 파싱되거나 표시되지 않습니다. `RedactionPolicy`는 값이 여러분의 로그에 표시되어도
되는 헤더와 쿼리 매개변수를 나열합니다.

이것은 안전망일 뿐 보장이 아닙니다. 직접 작성한 텍스트는 가릴 수 없고, URL 경로에 있는 짧은 비밀은 평범한 단어처럼 보일 수 있습니다. 비밀은
애초에 로그와 URL에 넣지 마세요. 전체 규칙과 한계는
[Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
문서에 있습니다.

## 문서

API 레퍼런스와 문서:

- [API 레퍼런스](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/)
  (DocC, `master`에서 GitHub Pages로 게시)
- 로컬에서는 Xcode의 **Product › Build Documentation**으로 빌드하거나 명령줄에서 빌드할 수 있습니다.

```sh
xcodebuild docbuild -scheme iOSFirebaseTools -destination 'generic/platform=macOS'
```

## 가이드

- [Getting Started](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/gettingstarted)
  — 패키지 추가, Firebase 프로젝트 준비, 로그인, 문서 저장
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/GettingStarted.md)).
- [Signing In](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/signingin)
  — 이메일, 익명, Apple, Google 로그인, 오류, 키체인 세션, 최신 토큰 유지
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/SigningIn.md)).
- [Working with Firestore](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/workingwithfirestore)
  — 모델, 쿼리, 쓰기, 변환, 일괄 쓰기, 트랜잭션, 클라이언트가 검사하는 한도
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/WorkingWithFirestore.md)).
- [Verifying ID Tokens](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/verifyingidtokens)
  — Swift 서버에서의 Firebase 규칙, 키 캐싱, 클레임, 시계 오차
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/VerifyingIDTokens.md)).
- [Testing with the Emulators](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/testingwiththeemulators)
  — Local Emulator Suite, `emulators:exec`, 테스트용 transport를 사용한 단위 테스트
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/TestingWithTheEmulators.md)).
- [Logging and Redaction](https://muhittincamdali.github.io/iOSFirebaseTools/documentation/iosfirebasetools/loggingandredaction)
  — 요청, 세션, 오류가 로그에 표시하는 내용, 허용 목록, 그리고 찾아내지 못하는 것
  ([소스](Sources/iOSFirebaseTools/iOSFirebaseTools.docc/LoggingAndRedaction.md)).

## 요구 사항

| 플랫폼      | 최소 버전                 |
| -------- | --------------------- |
| iOS      | 17                    |
| macOS    | 14                    |
| tvOS     | 17                    |
| watchOS  | 10                    |
| visionOS | 1                     |
| 툴체인      | Swift 6.2 · Xcode 26+ |

이 패키지는 Security 프레임워크와 CryptoKit을 사용하므로 Linux에서는 빌드되지 않습니다. CI는
GitHub `macos-26` 러너 이미지의 기본 Xcode로 빌드하며, 패키지는 Xcode 27로 개발합니다.
에뮬레이터 테스트에는 Firebase CLI와 Java 21 이상이 필요합니다.

## 아키텍처

- `Project/`: `FirebaseProject`(프로젝트 ID, API 키, 데이터베이스, 에뮬레이터)와 plist를 읽고
  검사하는 `GoogleServiceInfo`.
- `Auth/`: Identity Toolkit 및 Secure Token REST API를 다루는 actor인 `FirebaseAuthClient`,
  `AuthSession`과 이를 저장하는 `SessionStore`(키체인 또는 메모리), 제공자별 자격 증명.
- `Firestore/`: Firestore REST API를 다루는 `Sendable` struct인 `FirestoreClient`, JSON
  형식을 가진 `FirestoreValue`, `Codable` 인코더와 디코더, 경로, 쿼리, `WriteBatch`와
  `FirestoreTransaction`. 모든 쓰기는 `commit` 엔드포인트를 거치므로 단일 쓰기, 일괄 쓰기, 트랜잭션이 같은 방식으로
  동작합니다.
- `Tokens/`: `JSONWebToken` 파싱, `IDTokenClaims`, Google의 JSON Web Key Set에 있는 RSA 키를 쓰는
  `IDTokenVerifier`.
- `Transport/`: `HTTPTransport` 프로토콜과 `URLSession` 구현으로, 네트워크에 접근하는 유일한 곳입니다.
- `Support/`: `Secret`, `ValidationError`, 그리고 모든 텍스트 표현이 공유하는 가림 규칙.
- 프로세스 외부에서 들어오는 입력에는 한도가 있습니다. 응답 본문(16 MiB), 토큰(16 KiB), plist(64 KiB),
  중첩 깊이, 변환 전의 숫자 범위, 에뮬레이터 주소(`host:port`만 허용)입니다.

테스트를 로컬에서 실행합니다.

```sh
swift test                                      # macOS, emulator suite skipped
firebase emulators:exec --config Emulators/firebase.json --project demo-iosfirebasetools 'swift test'
xcodebuild test -scheme iOSFirebaseTools -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## 로드맵

- 패키지를 Swift Package Index에 추가하기(`.spi.yml`은 이미 저장소에 있습니다).
- 기존 사용자에 제공자 연결하기, 이메일 인증.
- swift-crypto 기반의 `IDTokenVerifier` Linux 빌드.

실시간 리스너와 오프라인 캐시는 계획에 없습니다. 둘 다 Firestore의 gRPC 스트리밍 연결이 필요한데,
REST API는 이를 제공하지 않기 때문입니다.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/iOSFirebaseTools/blob/master/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
