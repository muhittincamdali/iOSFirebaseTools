// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSFirebaseTools",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "iOSFirebaseTools", targets: ["iOSFirebaseTools"]),
        .library(name: "AuthenticationTools", targets: ["AuthenticationTools"]),
        .library(name: "AnalyticsTools", targets: ["AnalyticsTools"]),
        .library(name: "FirestoreTools", targets: ["FirestoreTools"]),
        .library(name: "StorageTools", targets: ["StorageTools"]),
        .library(name: "MessagingTools", targets: ["MessagingTools"]),
        .library(name: "SecurityTools", targets: ["SecurityTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.9.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "iOSFirebaseTools",
            dependencies: [
                "AuthenticationTools",
                "AnalyticsTools",
                "FirestoreTools",
                "StorageTools",
                "MessagingTools",
                "SecurityTools"
            ]
        ),
        .target(
            name: "AuthenticationTools",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "AnalyticsTools",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "FirestoreTools",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "StorageTools",
            dependencies: [
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "MessagingTools",
            dependencies: [
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "SecurityTools",
            dependencies: [
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "iOSFirebaseToolsTests",
            dependencies: ["iOSFirebaseTools"]
        )
    ]
) 