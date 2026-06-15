// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSFirebaseTools",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "iOSFirebaseTools", targets: ["iOSFirebaseTools"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "iOSFirebaseTools",
            dependencies: [],
            path: "Sources/iOSFirebaseTools",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "iOSFirebaseToolsTests",
            dependencies: ["iOSFirebaseTools"]
        )
    ]
)
