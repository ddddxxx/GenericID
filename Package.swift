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
        .package(url: "https://github.com/cx-org/CXShim", .upToNextMinor(from: "0.4.0"))
    ],
    targets: [
        .target(name: "GenericID", dependencies: ["CXShim"]),
        .testTarget(name: "GenericIDTests", dependencies: ["GenericID"]),
    ]
)

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

import Foundation

let combineImpl = ProcessInfo.processInfo.combineImplementation

if combineImpl == .combine {
    package.platforms = [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)]
}
