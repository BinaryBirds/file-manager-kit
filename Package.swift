// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "file-manager-kit",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "FileManagerKit", targets: ["FileManagerKit"]),
    ],
    targets: [
        .target(name: "FileManagerKit"),
        .testTarget(name: "FileManagerKitTests", dependencies: ["FileManagerKit"]),
    ]
)
