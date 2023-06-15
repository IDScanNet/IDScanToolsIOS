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
            name: "IDSSystemInfo",
            targets: ["IDSSystemInfo"]),
        .library(
            name: "IDSLocationManager",
            targets: ["IDSLocationManager"]),
    ],
    targets: [
        .target(
            name: "IDSSystemInfo"
        ),
        .target(
            name: "IDSLocationManager"
        )
    ]
)
