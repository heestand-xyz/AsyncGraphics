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
        .package(url: "https://github.com/heestand-xyz/TextureMap", .upToNextMinor(from: "0.6.1")),
        .package(url: "https://github.com/heestand-xyz/PixelColor", .upToNextMinor(from: "1.3.4")),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", .upToNextMinor(from: "1.3.2")),
        .package(url: "https://github.com/heestand-xyz/VideoFrames", .upToNextMinor(from: "0.2.3")),
        .package(url: "https://github.com/heestand-xyz/VoxelView", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: ["TextureMap", "PixelColor", "CoreGraphicsExtensions", "VideoFrames", "VoxelView"],
            resources: [
                .process("Graphics/Content/Solid/Metal/SolidMetal.metal.txt"),
                .process("Graphics/Content/Solid/Metal/SolidMetal3D.metal.txt"),
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
