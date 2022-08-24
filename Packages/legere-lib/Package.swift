// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "legere-lib",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(
            name: "LegereLib",
            targets: ["Domain"]
        ),
        .library(
            name: "LegereDeps",
            targets: ["Concrete"]
        ),
        .library(
            name: "LegereUI",
            targets: ["UINovelChapterPage", "AttributedRubyAnnotation"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3"),
        .package(url: "https://github.com/swiftty/DataCacheKit.git", branch: "main")
    ],
    targets: [
        // MARK: - utils
        .target(
            name: "AttributedRubyAnnotation"
        ),

        // MARK: - core domain
        .target(
            name: "Domain"
        ),

        // MARK: - ui components
        .target(
            name: "UIDomain",
            dependencies: [
                "Domain"
            ]
        ),
        .target(
            name: "UINovelChapterPage",
            dependencies: [
                "UIDomain"
            ]
        ),

        // MARK: - dependencies
        .target(
            name: "Concrete",
            dependencies: [
                "Domain",
                "NarouKit",
                "DataCacheKit"
            ]
        ),
        .target(
            name: "NarouKit",
            dependencies: [
                "Domain",
                "AttributedRubyAnnotation",
                "SwiftSoup"
            ]
        ),
        .testTarget(
            name: "NarouKitTests",
            dependencies: [
                "NarouKit"
            ]
        )
    ]
)
