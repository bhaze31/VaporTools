// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simmer",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "simmer", targets: ["simmer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4"),
    ],
    targets: [
        .executableTarget(
            name: "simmer",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [.copy("DefaultFiles")]),
        .testTarget(
            name: "simmer-tests",
            dependencies: ["simmer"]),
    ]
)
