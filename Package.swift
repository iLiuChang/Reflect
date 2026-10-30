// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Reflect",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "Reflect", targets: ["Reflect"])
    ],
    targets: [
        .target(
            name: "Reflect",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
