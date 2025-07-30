# FileManagerKit

Swift extensions and DSLs for filesystem testing, scripting, and inspection.

This package contains two products:

- FileManagerKit – high-level extensions for FileManager
- FileManagerKitBuilder – a DSL for creating filesystem layouts (ideal for tests)

Note: This repository is a work in progress. Expect breaking changes before v1.0.0.


## Installation

Add the package to your `Package.swift` to the package dependencies section:

```swift
.package(url: "https://github.com/binarybirds/file-manager-kit", .upToNextMinor(from: "0.4.0")),
```

Then add the library to the target dependencies:

```swift
.product(name: "FileManagerKit", package: "file-manager-kit"),
```

Also add the other library too, if you need the builder:

```swift
.product(name: "FileManagerKitBuilder", package: "file-manager-kit"),
```


## Usage

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
