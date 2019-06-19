// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Nimbus",
    platforms: [
        .macOS(.v10_14), .iOS(.v11)
    ],
    products: [
        .library(
            name: "Nimbus",
            targets: ["Nimbus"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Nimbus",
            path: "platforms/apple/Sources/Nimbus"),
        .testTarget(
            name: "NimbusTests",
            dependencies: ["Nimbus"],
            path: "platforms/apple/Sources/NimbusTests"),
    ],
    swiftLanguageVersions: [.v4_2]
)
