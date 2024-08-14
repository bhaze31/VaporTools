// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simmer",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "simmer", targets: ["simmer"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.12.0"),
        .package(url: "https://github.com/vapor/console-kit", from: "4.12.0")
    ],
    targets: [
        .executableTarget(
            name: "simmer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "ConsoleKit", package: "console-kit")
            ],
            resources: [.copy("DefaultFiles")]),
        .testTarget(
            name: "simmer-tests",
            dependencies: ["simmer"]),
    ]
)
