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
         .package(url: "https://github.com/heestand-xyz/TextureMap", exact: "0.3.0"),
         .package(url: "https://github.com/heestand-xyz/PixelColor", exact: "1.3.4"),
         .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: ["TextureMap", "PixelColor", "CoreGraphicsExtensions"]),
        .testTarget(
            name: "AsyncGraphicsTests",
            dependencies: ["AsyncGraphics", "TextureMap", "PixelColor"],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
