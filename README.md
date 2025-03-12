# FileManagerKit

Useful extensions for the [FileManager](https://developer.apple.com/documentation/foundation/filemanager) class.

## Getting started

⚠️ This repository is a work in progress, things can break until it reaches v1.0.0. 

Use at your own risk.

### Adding the dependency

To add a dependency on the package, declare it in your `Package.swift`:

```swift
.package(url: "https://github.com/binarybirds/file-manager-kit", .upToNextMinor(from: "0.2.0")),
```

and to your application target, add `FileManagerKit` to your dependencies:

```swift
.product(name: "FileManagerKit", package: "file-manager-kit")
```

Example `Package.swift` file with `FileManagerKit` as a dependency:

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "my-application",
    dependencies: [
        .package(url: "https://github.com/binarybirds/file-manager-kit", .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(name: "MyApplication", dependencies: [
            .product(name: "FileManagerKit", package: "file-manager-kit")
        ]),
        .testTarget(name: "MyApplicationTests", dependencies: [
            .target(name: "MyApplication"),
        ]),
    ]
)
```

