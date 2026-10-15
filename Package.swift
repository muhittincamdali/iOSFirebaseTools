// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "iOSFirebaseTools",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "iOSFirebaseTools", targets: ["iOSFirebaseTools"])
    ],
    targets: [
        .target(
            name: "iOSFirebaseTools",
            path: "Sources/iOSFirebaseTools"
        ),
        .testTarget(
            name: "iOSFirebaseToolsTests",
            dependencies: ["iOSFirebaseTools"]
        )
    ]
)
