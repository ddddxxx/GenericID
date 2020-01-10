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
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "GenericID",
            dependencies: ["CXShim"]),
        .testTarget(
            name: "GenericIDTests",
            dependencies: ["GenericID"]),
    ]
)
