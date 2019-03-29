// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenericID",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(
            name: "GenericID",
            targets: ["GenericID"]),
    ],
    targets: [
        .target(
            name: "GenericID",
            dependencies: []),
        .testTarget(
            name: "GenericIDTests",
            dependencies: ["GenericID"]),
    ]
)
