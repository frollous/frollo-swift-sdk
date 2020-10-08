// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrolloSDK",
    products: [
        .library(
            name: "FrolloSDK",
            targets: ["FrolloSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "FrolloSDK",
            dependencies: [],
            path: "./Sources/"),
        .testTarget(
            name: "FrolloSDKTests",
            dependencies: ["FrolloSDK"],
            path: "./Tests/"),
    ]
)
