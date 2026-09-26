// swift-tools-version: 6.0
//
// Package.swift in Package@swift-6.0/ is a minimal manifest used by SwiftPM and
// Xcode's "Add Package Dependency" to discover this package for indexing and
// search. It declares the package name, the library product, and the minimum
// platform versions so consumers can resolve it.
//
// It intentionally omits the test target — the Swift Package Index only indexes
// the public library, and tests are defined in the main Package.swift.
import PackageDescription

let package = Package(
    name: "SessionTime",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SessionTime",
            targets: ["SessionTime"]
        ),
    ],
    targets: [
        .target(
            name: "SessionTime"
        ),
    ]
)
