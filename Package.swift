// swift-tools-version: 5.5

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
        .package(url: "https://github.com/heestand-xyz/TextureMap", .exact("0.5.1")),
        .package(url: "https://github.com/heestand-xyz/PixelColor", .exact("1.3.4")),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", .exact("1.3.1")),
        .package(url: "https://github.com/heestand-xyz/VideoFrames", .exact("0.2.1")),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: ["TextureMap", "PixelColor", "CoreGraphicsExtensions", "VideoFrames"],
            resources: [
                .process("Graphics/Content/Solid/Metal/SolidMetal.metal.txt"),
                .process("Graphics/Effects/Direct/Metal/DirectMetal.metal.txt"),
                .process("Graphics/Effects/Dual/Metal/DualMetal.metal.txt"),
                .process("Graphics/Effects/Array/Metal/ArrayMetal.metal.txt"),
            ]),
        .testTarget(
            name: "AsyncGraphicsTests",
            dependencies: ["AsyncGraphics", "TextureMap", "PixelColor"],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
