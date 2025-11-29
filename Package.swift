// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ai-experiment",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "ai-experiment",
            targets: ["ai-experiment"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ai-experiment",
            resources: [
                .copy("credentials.json"),
                .copy("prompt.md")
            ]
        ),
    ]
)
