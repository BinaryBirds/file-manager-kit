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
        .library(name: "FileManagerKit", targets: ["FileManagerKit"]),
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
        .testTarget(
            name: "FileManagerKitTests",
            dependencies: [
                .target(name: "FileManagerKit")
            ]
        ),
    ]
)
