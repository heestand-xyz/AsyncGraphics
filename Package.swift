// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AsyncGraphics",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AsyncGraphics",
            targets: ["AsyncGraphics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/TextureMap", from: "2.2.0"),
        .package(url: "https://github.com/heestand-xyz/PixelColor", from: "3.2.0"),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "2.0.1"),
        .package(url: "https://github.com/heestand-xyz/SpatialExtensions", from: "1.0.0"),
        .package(url: "https://github.com/heestand-xyz/VideoFrames", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
    ],
    targets: [
        .target(
            name: "AsyncGraphics",
            dependencies: [
                "TextureMap",
                "PixelColor",
                "CoreGraphicsExtensions",
                "SpatialExtensions",
                "VideoFrames",
                "AsyncGraphicsMacros",
            ],
            resources: [
                .process("Localizable.xcstrings"),
                .process("Graphics/Content/Solid/Metal/SolidMetal.metal.txt"),
                .process("Graphics/Content/Solid/Metal/SolidMetal3D.metal.txt"),
                .process("Graphics/Effects/Space/Metal/DirectMetal.metal.txt"),
                .process("Graphics/Effects/Modifier/Metal/DualMetal.metal.txt"),
                .process("Graphics/Effects/Sequence/Metal/ArrayMetal.metal.txt"),
            ]),
        .macro(
            name: "AsyncGraphicsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]),
        .testTarget(
            name: "AsyncGraphicsTests",
            dependencies: [
                "AsyncGraphics",
                "TextureMap",
                "PixelColor"
            ],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
