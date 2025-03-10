// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ECWeekView",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ECWeekView", type: .dynamic, targets: ["ECWeekView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EvanCooper9/ECKit", branch: "main"),
        .package(url: "https://github.com/EvanCooper9/ECScrollView", from: "1.0.0")
    ],
    targets: [
        .target(name: "ECWeekView", dependencies: ["ECKit", "ECScrollView"], path: "Sources"),
        .testTarget(name: "ECWeekViewTests", dependencies: ["ECWeekView"], path: "Tests")
    ]
)
