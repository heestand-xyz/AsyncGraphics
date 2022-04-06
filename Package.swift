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
         .package(url: "https://github.com/heestand-xyz/TextureMap", exact: "0.4.0"),
         .package(url: "https://github.com/heestand-xyz/PixelColor", exact: "1.3.4"),
         .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", exact: "1.3.0"),
         .package(url: "https://github.com/heestand-xyz/VideoFrames", exact: "0.2.0"),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: ["TextureMap", "PixelColor", "CoreGraphicsExtensions", "VideoFrames"]),
        .testTarget(
            name: "AsyncGraphicsTests",
            dependencies: ["AsyncGraphics", "TextureMap", "PixelColor"],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
