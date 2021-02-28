// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrolloSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "FrolloSDK",
            targets: ["FrolloSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.0"),
        .package(name: "AppAuth", url: "https://github.com/openid/AppAuth-iOS.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),

    ],
    targets: [
        .target(
            name: "FrolloSDK",
            dependencies: ["Alamofire", "AppAuth", "SwiftyJSON"],
            exclude: ["Bundle+Resources.swift"],
            resources: [.process("Resources")]
        ),
//        .testTarget(
//            name: "FrolloSDKTests",
//            dependencies: ["FrolloSDK", "OHHTTPStubs", .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")],
//            resources: [.process("Resources")]
//        ),
    ]
)
