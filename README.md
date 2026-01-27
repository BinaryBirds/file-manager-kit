# FileManagerKit

Swift extensions and DSLs for filesystem testing, scripting, and inspection.

![Release: 0.5.0](https://img.shields.io/badge/Release-0%2E5%2E0-F05138)

## Features

This package contains two products:

- FileManagerKit – high-level extensions for FileManager
- FileManagerKitBuilder – a DSL for creating filesystem layouts (ideal for tests)

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: Linux, macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-Linux_%7C_macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)

- Swift 6.1+

- Platforms:
  - Linux
  - macOS 15+
  - iOS 18+
  - tvOS 18+
  - watchOS 11+
  - visionOS 2+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/binarybirds/file-manager-kit", .exact: "1.0.0-beta.1"),
```

Then add `FileManagerKit` to your target dependencies:

```swift
.product(name: "FileManagerKit", package: "file-manager-kit"),
```

Also add the other library too, if you need the builder:

```swift
.product(name: "FileManagerKitBuilder", package: "file-manager-kit"),
```

## Usage

![DocC documentation](https://img.shields.io/badge/DocC-documentation-F05138)
Documentation is available at the following [link](https://binarybirds.github.io/file-manager-kit).
Here are a few common use-cases.

### FileManagerKit

A set of ergonomic, safe extensions for working with FileManager.

Check if file or directory exists:

```swift
let fileURL = URL(filePath: "/path/to/file")
if fileManager.exists(at: fileURL) {
    print("Exists!")
}
```

Create a directory:

```swift
let dirURL = URL(filePath: "/path/to/new-dir")
try fileManager.createDirectory(at: dirURL)
```

Create a file:

```swift
let fileURL = URL(filePath: "/path/to/file.txt")
let data = "Hello".data(using: .utf8)
try fileManager.createFile(at: fileURL, contents: data)
```

Delete a file or directory:

```swift
let targetURL = URL(filePath: "/path/to/delete")
try fileManager.delete(at: targetURL)
```

List directory contents:

```swift
let contents = fileManager.listDirectory(at: URL(filePath: "/path/to/dir"))
print(contents)
```

Copy and move:

```swift
try fileManager.copy(from: URL(filePath: "/from"), to: URL(filePath: "/to"))

try fileManager.move(from: URL(filePath: "/from"), to: URL(filePath: "/to"))
```

Get file size information:

```swift
let size = try fileManager.size(at: URL(filePath: "/path/to/file"))
print("\(size) bytes")
```

### FileManagerKitBuilder

A Swift DSL to declaratively build, inspect, and tear down file system structures — great for testing.

Simple Example to create and clean up a file structure:

```swift
import FileManagerKitBuilder

let playground = FileManagerPlayground {
    Directory(name: "foo") {
        File(name: "bar.txt", string: "Hello, world!")
    }
}

let _ = try playground.build()
try playground.remove()
```

Custom type example, you can use a `BuildableItem` to generate structured files (e.g., JSON):

```swift
public struct JSON<T: Encodable>: BuildableItem {
    public let name: String
    public let contents: T

    public func buildItem() -> FileManagerPlayground.Item {
        let data = try! JSONEncoder().encode(contents)
        let string = String(data: data, encoding: .utf8)!
        return .file(File(name: "\(name).json", string: string))
    }
}

struct User: Codable { let name: String }

let playground = FileManagerPlayground {
    Directory(name: "data") {
        JSON(name: "user", contents: User(name: "Deku"))
    }
}

try playground.build()
```

Use `.test` to run assertions in a temporary sandbox:

```swift
try FileManagerPlayground {
    Directory(name: "foo") {
        "bar.txt"
    }
}
.test { fileManager, rootUrl in
    let fileURL = rootUrl.appending(path: "foo/bar.txt")
    #expect(fileManager.fileExists(at: fileURL))
}
```

## Development

- Build: `swift build`
- Test:
  - local: `swift test`
  - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/BinaryBirds/file-manager-kit/pulls) are welcome. Please keep changes focused and include tests for new logic. 🙏
