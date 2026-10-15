// swift-tools-version: 6.2
import PackageDescription

// fbcheck: checks a GoogleService-Info.plist and verifies Firebase ID tokens, using
// iOSFirebaseTools from this checkout.
let package = Package(
    name: "ConfigCheck",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "iOSFirebaseTools", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "fbcheck",
            dependencies: [.product(name: "iOSFirebaseTools", package: "iOSFirebaseTools")]
        )
    ]
)
