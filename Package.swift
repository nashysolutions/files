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
    dependencies: [
        .package(url: "https://github.com/nashysolutions/error-presentation.git", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "Files",
            dependencies: [
                .product(name: "ErrorPresentation", package: "error-presentation")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FilesTests",
            dependencies: ["Files"]
        )
    ]
)
