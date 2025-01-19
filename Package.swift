// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "files",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Files",
            targets: ["Files"]),
    ],
    targets: [
        .target(
            name: "Files"),
        .testTarget(
            name: "FilesTests",
            dependencies: ["Files"]
        )
    ]
)
