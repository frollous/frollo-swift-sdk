// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrolloSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .tvOS(.v10),
        .watchOS(.v4)
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
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.1.0"))
    ],
    targets: [
        .target(
            name: "FrolloSDK",
            dependencies: ["Alamofire", "AppAuth", "SwiftyJSON"],
            exclude: ["Bundle+Resources.swift", "Info.plist", "FrolloSDKCore-Info.plist"],
            resources: [.process("Resources")]
        ),
        /*.testTarget(
            name: "FrolloSDKiOSTests",
            dependencies: [
                .byName(name: "FrolloSDK"),
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            path: "Tests",
            exclude: ["Bundle+Resources.swift"],
            resources: [.process("Resources"),
                        .process("Sources/FrolloSDK/Resources/Database")]
        )*/
    ],
    swiftLanguageVersions: [.v5]
)
