// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tools",
    platforms: [
        .macOS(.v12)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.32.0")
    ],
    targets: []
)
