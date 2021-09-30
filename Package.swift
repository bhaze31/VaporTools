// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rapid-boil",
    products: [
        .executable(name: "rapid-boil", targets: ["rapid-boil"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "rapid-boil",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "rapid-boil-tests",
            dependencies: ["rapid-boil"]),
    ]
)
