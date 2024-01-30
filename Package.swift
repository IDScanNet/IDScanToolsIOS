// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IDScanToolsIOS",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "IDSCommonTools",
            targets: ["IDSCommonTools"]),
        .library(
            name: "IDSSystemInfo",
            targets: ["IDSSystemInfo"]),
        .library(
            name: "IDSLocationManager",
            targets: ["IDSLocationManager"])
    ],
    dependencies: [
        .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift.git", from: "21.0.0")
    ],
    targets: [
        .target(
            name: "IDSCommonTools"
        ),
        .target(
            name: "IDSSystemInfo",
            dependencies: [
                "IDSCommonTools",
                .product(name: "KeychainSwift", package: "KeychainSwift")
            ]
        ),
        .target(
            name: "IDSLocationManager"
        )
    ]
)
