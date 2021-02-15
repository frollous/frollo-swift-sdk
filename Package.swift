// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrolloSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "FrolloSDK",
            targets: ["FrolloSDK"]),
    ],
    dependencies: [
    ],
    targets: [
      .binaryTarget(
        name: "FrolloSDK",
        path: "./Sources/FrolloSDK.xcframework")
    ]
)
