# FileManagerKit

Swift extensions and DSLs for filesystem testing, scripting, and inspection.

This package contains two products:

- FileManagerKit – high-level extensions for FileManager
- FileManagerKitBuilder – a DSL for creating filesystem layouts (ideal for tests)

Note: This repository is a work in progress. Expect breaking changes before v1.0.0.

---

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/binarybirds/file-manager-kit", .upToNextMinor(from: "0.2.0")),
```

Then declare the product you want to use in your target dependencies:

```swift
.product(name: "FileManagerKit", package: "file-manager-kit")
.product(name: "FileManagerKitBuilder", package: "file-manager-kit")
```

---

# FileManagerKit

A set of ergonomic, safe extensions for working with FileManager.

## Common Operations

### Check if File or Directory Exists

```swift
let fileURL = URL(filePath: "/path/to/file")
if fileManager.exists(at: fileURL) {
    print("Exists!")
}
```

### Create a Directory

```swift
let dirURL = URL(filePath: "/path/to/new-dir")
try fileManager.createDirectory(at: dirURL)
```

### Create a File

```swift
let fileURL = URL(filePath: "/path/to/file.txt")
let data = "Hello".data(using: .utf8)
try fileManager.createFile(at: fileURL, contents: data)
```

### Delete a File or Directory

```swift
let targetURL = URL(filePath: "/path/to/delete")
try fileManager.delete(at: targetURL)
```

### List Directory Contents

```swift
let contents = fileManager.listDirectory(at: URL(filePath: "/path/to/dir"))
print(contents)
```

### Copy / Move

```swift
try fileManager.copy(from: URL(filePath: "/from"), to: URL(filePath: "/to"))
try fileManager.move(from: URL(filePath: "/from"), to: URL(filePath: "/to"))
```

### Get File Size

```swift
let size = try fileManager.size(at: URL(filePath: "/path/to/file"))
print("\(size) bytes")
```

---

# FileManagerKitBuilder

A Swift DSL to declaratively build, inspect, and tear down file system structures — great for testing.

## Installation

To use FileManagerKitBuilder, add this line to your dependencies:

```swift
.product(name: "FileManagerKitBuilder", package: "file-manager-kit")
```

## Simple Example

Create and clean up a file structure:

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

## Custom Type Example

Use a BuildableItem to generate structured files (e.g., JSON).

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

## Test Example

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
