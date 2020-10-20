// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "frollo-ios-sdk",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "frollo-ios-sdk",
            targets: ["frollo-ios-sdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Alamofire/Alamofire", from: "5.3.0"),
        .package(name: "AppAuth", url: "https://github.com/openid/AppAuth-iOS", from: "1.4.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "frollo-ios-sdk",
            dependencies: ["Alamofire", "AppAuth", "SwiftyJSON"],
            path: "Sources"
            )
    ]
)
