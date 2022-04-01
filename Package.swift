// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AsyncGraphics",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AsyncGraphics",
            targets: ["AsyncGraphics"]),
    ],
    dependencies: [
         .package(url: "https://github.com/heestand-xyz/TextureMap", from: "0.1.1"),
//         .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.2.1"),
//         .package(url: "https://github.com/heestand-xyz/Logger", from: "0.2.1"),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: ["TextureMap"/*, "CoreGraphicsExtensions", "Logger"*/]),
        .testTarget(
            name: "AsyncGraphicsTests",
            dependencies: ["AsyncGraphics"],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
