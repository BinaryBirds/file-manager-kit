// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "file-manager-kit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "FileManagerKit",
            targets: ["FileManagerKit"]
        ),
        .library(
            name: "FileManagerKitBuilder",
            targets: ["FileManagerKitBuilder"]
        ),
    ],
    dependencies: [
      
    ],
    targets: [
        .target(
            name: "FileManagerKit",
            dependencies: [
                
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
            ]
        ),
        .target(
            name: "FileManagerKitBuilder",
            dependencies: [
                
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
            ]
        ),
        .testTarget(
            name: "FileManagerKitTests",
            dependencies: [
                .target(name: "FileManagerKit"),
                .target(name: "FileManagerKitBuilder")
            ]
        ),
        .testTarget(
            name: "FileManagerKitBuilderTests",
            dependencies: [
                .target(name: "FileManagerKit"),
                .target(name: "FileManagerKitBuilder")
            ]
        ),
    ]
)
