// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScrollEngine",
    platforms: [
        .iOS(.v26),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ScrollEngine",
            targets: ["ScrollEngine"]
        ),
    ],
    targets: [
        .target(
            name: "ScrollEngine"
        ),
        .testTarget(
            name: "ScrollEngineTests",
            dependencies: ["ScrollEngine"]
        ),
    ]
)
