// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-math-parsing",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-math-parsing",
            targets: ["swift-math-parsing"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-math-parsing"),
        .testTarget(
            name: "swift-math-parsingTests",
            dependencies: ["swift-math-parsing"]),
    ]
)
