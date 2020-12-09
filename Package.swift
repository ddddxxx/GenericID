// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "GenericID",
    products: [
        .library(
            name: "GenericID",
            targets: ["GenericID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "GenericID",
            dependencies: [.product(name: "CXShim", package: "CombineX")]),
        .testTarget(
            name: "GenericIDTests",
            dependencies: ["GenericID"]),
    ]
)
