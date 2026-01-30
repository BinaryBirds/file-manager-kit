// swift-tools-version:6.1
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
var defaultSwiftSettings: [SwiftSetting] =
[
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0441-formalize-language-mode-terminology.md
    .swiftLanguageMode(.v6),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    // https://github.com/swiftlang/swift/pull/65218
    .enableExperimentalFeature("AvailabilityMacro=featherDatabase 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
]

#if compiler(>=6.2)
defaultSwiftSettings.append(
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
)
#endif

let package = Package(
    name: "file-manager-kit",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
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
        // [docc-plugin-placeholder]
    ],
    targets: [
        .target(
            name: "FileManagerKit",
            swiftSettings: defaultSwiftSettings

        ),
        .target(
            name: "FileManagerKitBuilder",
            dependencies: [
                .target(name: "FileManagerKit"),
            ],
            swiftSettings: defaultSwiftSettings

        ),
        .testTarget(
            name: "FileManagerKitTests",
            dependencies: [
                .target(name: "FileManagerKit"),
                .target(name: "FileManagerKitBuilder")
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FileManagerKitBuilderTests",
            dependencies: [
                .target(name: "FileManagerKit"),
                .target(name: "FileManagerKitBuilder")
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
