    // swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BugKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "BugKit",
            targets: ["BugKit"]),
    ],
    dependencies: [],
    targets: [
        // Only keep the main target
        .target(
            name: "BugKit",
            dependencies: [])
    ]
)
