// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECWeekView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ECWeekView",
            targets: ["ECWeekView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EvanCooper9/ECTimelineView", from: "1.0.0"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "ECWeekView",
            dependencies: [
                .byName(name: "ECTimelineView"),
                .byName(name: "SwiftDate")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
