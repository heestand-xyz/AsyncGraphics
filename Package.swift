// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "LiveGraphics",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "LiveGraphics",
            targets: ["LiveGraphics"]),
    ],
    dependencies: [
         .package(url: "https://github.com/heestand-xyz/TextureMap", from: "0.1.1"),
         .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "LiveGraphics",
            dependencies: ["TextureMap", "CoreGraphicsExtensions"]),
        .testTarget(
            name: "LiveGraphicsTests",
            dependencies: ["LiveGraphics"],
            resources: [
                .process("TestAssets.xcassets")
            ]),
    ]
)
