// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lucide",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Lucide",
            targets: ["Lucide"]),
    ],
    targets: [
        .target(
            name: "Lucide",
            resources: [
                .copy("lucide.ttf")
            ]
        ),
    ]
)
