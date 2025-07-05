// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "files",
    defaultLocalization: .some("en"),
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "Files",
            targets: ["Files"]),
    ],
    targets: [
        .target(
            name: "Files",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FilesTests",
            dependencies: ["Files"]
        )
    ]
)
