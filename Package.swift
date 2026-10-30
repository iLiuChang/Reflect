// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Reflect",
    platforms: [.iOS(.v11)],
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
