import FileManagerKitTesting
import Foundation
import Testing

@testable import FileManagerKit

@Suite(.serialized)
struct FileManagerKitTestSuite {

    // MARK: - exists(at:) Tests

    @Test
    func exists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test { fileManager, rootUrl in
            let url = rootUrl.appending(path: "foo/bar")

            #expect(fileManager.exists(at: url))
        }
    }

    @Test
    func exists_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "does/not/exist")

                #expect(!$0.exists(at: url))
            }
    }

    // MARK: - fileExists(at:) Tests

    @Test
    func fileExists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")

            #expect($0.fileExists(at: url))
        }
    }

    @Test
    func fileExists_whenFolderExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")

            #expect(!$0.fileExists(at: url))
        }
    }

    @Test
    func fileExists_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "does/not/exist")

                #expect(!$0.fileExists(at: url))
            }
    }

    // MARK: - directoryExists(at:) Tests

    @Test
    func directoryExists_whenDirectoryExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo")

            #expect($0.directoryExists(at: url))
        }
    }

    @Test
    func directoryExists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")

            #expect(!$0.directoryExists(at: url))
        }
    }

    @Test
    func directoryExists_whenDirectoryDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "does/not/exist")

                #expect(!$0.directoryExists(at: url))
            }
    }

    // MARK: - createFile(at:) Tests

    @Test
    func createFile_whenCreatesFileSuccessfully() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "foo")
                try $0.createFile(at: url, contents: nil)

                #expect($0.fileExists(at: url))
            }
    }

    @Test
    func createFile_whenIntermediateDirectoriesMissing() throws {
        try FileManagerPlayground()
            .test { fileManager, rootUrl in
                let url = rootUrl.appending(path: "foo/bar/baz")

                #expect(
                    throws: CocoaError(.fileWriteUnknown),
                    performing: {
                        try fileManager.createFile(at: url, contents: nil)
                    }
                )
            }
    }

    @Test
    func createFile_whenFileAlreadyExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")
            let dataToWrite = "data".data(using: .utf8)
            try $0.createFile(at: url, contents: dataToWrite)
            let data = $0.contents(atPath: url.path())

            #expect(dataToWrite == data)
        }
    }

    // MARK: - createDirectory(at:) Tests

    @Test
    func createDirectory_whenCreatesDirectorySuccessfully() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "foo")
                try $0.createDirectory(at: url)

                #expect($0.directoryExists(at: url))
            }
    }

    @Test
    func createDirectory_whenDirectoryAlreadyExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")
            try $0.createDirectory(at: url)

            #expect($0.directoryExists(at: url))
        }
    }

    // MARK: - delete(at:) Tests

    @Test
    func delete_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")
            try $0.delete(at: url)

            #expect(!$0.fileExists(at: url))
        }
    }

    @Test
    func delete_whenDirectoryExists() throws {
        try FileManagerPlayground {
            Directory("foo")
        }
        .test {
            let url = $1.appending(path: "foo")
            try $0.delete(at: url)

            #expect(!$0.directoryExists(at: url))
        }
    }

    @Test
    func delete_whenDirectoryDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "foo")

                do {
                    try $0.delete(at: url)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 4)
                }
            }
    }

    // MARK: - listDirectory(at:) Tests

    @Test
    func listDirectory_whenDirectoryHasContent() throws {
        try FileManagerPlayground {
            Directory("a")
            Directory("b")
            Directory("c")
            File(".foo", string: "foo")
            "bar"
            SymbolicLink("bar_link", destination: "bar")
        }
        .test {
            let items = $0.listDirectory(at: $1).sorted()
            #expect(items == [".foo", "a", "b", "bar", "bar_link", "c"])
        }
    }

    @Test
    func listDirectory_whenDirectoryIsEmpty() throws {
        try FileManagerPlayground {
            Directory("foo")
        }
        .test {
            let url = $1.appending(path: "foo")
            let items = $0.listDirectory(at: url)
            #expect(items == [])
        }
    }

    @Test
    func listDirectory_whenPathIsNotDirectory() throws {
        try FileManagerPlayground {
            "foo"
        }
        .test {
            let url = $1.appending(path: "foo")
            let items = $0.listDirectory(at: url)
            #expect(items == [])
        }
    }

    // MARK: - copy(from:to:) Tests

    @Test
    func copy_whenSourceExists() throws {
        try FileManagerPlayground {
            "source"
        }
        .test {
            let source = $1.appending(path: "source")
            let destination = $1.appending(path: "destination")

            try $0.copy(from: source, to: destination)

            #expect($0.fileExists(at: destination))
            let originalData = $0.contents(atPath: source.path())
            let copiedData = $0.contents(atPath: destination.path())
            #expect(originalData == copiedData)
        }
    }

    @Test
    func copy_whenSourceDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let source = $1.appending(path: "nonexistent")
                let destination = $1.appending(path: "destination")

                do {
                    try $0.copy(from: source, to: destination)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 260)
                }
            }
    }

    @Test
    func copy_whenDestinationAlreadyExists() throws {
        try FileManagerPlayground {
            "source"
            "destination"
        }
        .test {
            let source = $1.appending(path: "source")
            let destination = $1.appending(path: "destination")

            do {
                try $0.copy(from: source, to: destination)
                #expect(Bool(false))
            }
            catch let error as NSError {
                #expect(error.domain == NSCocoaErrorDomain)
                #expect(error.code == 516)
            }
        }
    }

    // MARK: - move(from:to:) Tests

    @Test
    func move_whenSourceExists() throws {
        try FileManagerPlayground {
            "source"
        }
        .test {
            let source = $1.appending(path: "source")
            let destination = $1.appending(path: "destination")

            try $0.move(from: source, to: destination)

            #expect(!$0.fileExists(at: source))
            #expect($0.fileExists(at: destination))
        }
    }

    @Test
    func move_whenSourceDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let source = $1.appending(path: "nonexistent")
                let destination = $1.appending(path: "destination")

                do {
                    try $0.move(from: source, to: destination)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 4)
                }
            }
    }

    @Test
    func move_whenDestinationAlreadyExists() throws {
        try FileManagerPlayground {
            "source"
            "destination"
        }
        .test {
            let source = $1.appending(path: "source")
            let destination = $1.appending(path: "destination")

            do {
                try $0.move(from: source, to: destination)
                #expect(Bool(false))
            }
            catch let error as NSError {
                #expect(error.domain == NSCocoaErrorDomain)
                #expect(error.code == 516)
            }
        }
    }

    // MARK: - link(from:to:) Tests

    @Test
    func link_whenSourceExists() throws {
        try FileManagerPlayground {
            File("sourceFile", string: "Hello, world!")
        }
        .test {
            let source = $1.appending(path: "sourceFile")
            let destination = $1.appending(path: "destination")
            try $0.link(from: source, to: destination)
            let exists = $0.exists(at: destination)
            let attributes = try $0.attributes(at: destination)
            let fileType = attributes[.type] as? FileAttributeType

            #expect($0.linkExists(at: destination))
            #expect(exists)
            #expect(fileType == .typeSymbolicLink)
        }
    }

    @Test
    func link_whenSourceDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let source = $1.appending(path: "missingSource")
                let destination = $1.appending(path: "destination")
                try $0.link(from: source, to: destination)
                let attributes = try $0.attributes(at: destination)
                let fileType = attributes[.type] as? FileAttributeType

                #expect(fileType == .typeSymbolicLink)

                #expect($0.linkExists(at: destination))

                // Check that resolving the symlink gives the expected (absolute) path
                let resolvedPath = try $0.destinationOfSymbolicLink(
                    atPath: destination.path()
                )
                #expect(
                    URL(fileURLWithPath: resolvedPath).lastPathComponent
                        == source.lastPathComponent
                )

                // Check that the target file does not exist (dangling link)
                #expect(!$0.fileExists(atPath: resolvedPath))
            }
    }

    @Test
    func link_whenDestinationAlreadyExists() throws {
        try FileManagerPlayground {
            "source"
            "destination"
        }
        .test {
            let source = $1.appending(path: "source")
            let destination = $1.appending(path: "destination")

            do {
                try $0.link(from: source, to: destination)
                #expect(Bool(false))
            }
            catch let error as NSError {
                #expect(error.domain == NSCocoaErrorDomain)
                #expect(error.code == 516)
            }
        }
    }

    // MARK: - creationDate(at:) Tests

    @Test
    func creationDate_whenFileExists() throws {
        try FileManagerPlayground {
            "file"
        }
        .test {
            let file = $1.appending(path: "file")

            let creationDate = try $0.creationDate(at: file)
            let attributes = try $0.attributesOfItem(atPath: file.path())

            let creationDateAttribute = attributes[.creationDate] as? Date
            let modDateAttribute = attributes[.modificationDate] as! Date
            let dateAttrbiute = creationDateAttribute ?? modDateAttribute

            #expect(creationDate == dateAttrbiute)
        }
    }

    @Test
    func creationDate_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let file = $1.appending(path: "nonexistent")

                do {
                    _ = try $0.creationDate(at: file)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 260)
                }
            }
    }

    // MARK: - modificationDate(at:) Tests

    @Test
    func modificationDate_whenFileExists() throws {
        try FileManagerPlayground {
            "file"
        }
        .test {
            let file = $1.appending(path: "file")

            let modificationDate = try $0.modificationDate(at: file)
            let attributes = try $0.attributesOfItem(atPath: file.path())

            #expect(modificationDate == attributes[.modificationDate] as? Date)
        }
    }

    @Test
    func modificationDate_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let file = $1.appending(path: "nonexistent")

                do {
                    _ = try $0.modificationDate(at: file)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 260)
                }
            }
    }

    // MARK: - size(at:) Tests

    @Test
    func size_whenFileExists() throws {
        try FileManagerPlayground {
            let text = "Hello, world!"
            File("file", string: text)
        }
        .test {
            let file = $1.appending(path: "file")

            let fileSize = try $0.size(at: file)
            let expectedSize = "Hello, world!".utf8.count

            #expect(fileSize == expectedSize)
        }
    }

    @Test
    func size_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let file = $1.appending(path: "nonexistent")
                let size = try $0.size(at: file)

                #expect(size == 0)
            }
    }

    // MARK: - setAttributes(at:attributes:) Tests

    @Test
    func setAttributes_whenFileExists() throws {
        try FileManagerPlayground {
            "file"
        }
        .test {
            let url = $1.appending(path: "file")

            let newDate = Date(timeIntervalSince1970: 10000)
            let attributes: [FileAttributeKey: Any] = [
                .modificationDate: newDate
            ]
            try $0.setAttributes(attributes, at: url)
            let updatedAttributes = try $0.attributes(at: url)

            #expect(updatedAttributes[.modificationDate] as? Date == newDate)
        }
    }

    @Test
    func setAttributes_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "nonexistent")

                do {
                    let attributes: [FileAttributeKey: Any] = [
                        .modificationDate: Date()
                    ]
                    try $0.setAttributes(attributes, at: url)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 4)
                }
            }
    }

    // MARK: - setPermissions(at:permissions:) Tests

    @Test
    func setPermissions_whenFileExists() throws {
        try FileManagerPlayground {
            "file"
        }
        .test {
            let url = $1.appending(path: "file")

            let permissions = 600
            try $0.setPermissions(permissions, at: url)
            let updatedPermissions = try $0.permissions(at: url)

            #expect(updatedPermissions == permissions)
        }
    }

    @Test
    func setPermissions_whenFileDoesNotExist() throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "nonexistent")

                do {
                    try $0.setPermissions(600, at: url)
                    #expect(Bool(false))
                }
                catch let error as NSError {
                    #expect(error.domain == NSCocoaErrorDomain)
                    #expect(error.code == 4)
                }
            }
    }

    @Test
    func listDirectoryRecursively() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bap"
                Directory("bar") {
                    "beep"
                    Directory("baz") {
                        "boop"
                    }
                }
            }
        }
        .test {
            let baseUrlLength = $1.path().count
            let results = $0.listDirectoryRecursively(at: $1)
                .map { String($0.path().dropFirst(baseUrlLength)) }
                .sorted()
            let expected = ["foo/bap", "foo/bar/baz/boop", "foo/bar/beep"]

            #expect(expected == results)
        }
    }

    @Test
    func copyDirectoryRecursively() throws {
        try FileManagerPlayground {
            Directory("from") {
                Directory("foo") {
                    "bap"
                    Directory("bar") {
                        "beep"
                        Directory("baz") {
                            "boop"
                        }
                    }
                }
            }
            Directory("to")
        }
        .test {
            let from = $1.appendingPathComponent("from")
            let to = $1.appendingPathComponent("to")

            try $0.copyRecursively(from: from, to: to)

            let baseUrlLength = to.path().count
            let results = $0.listDirectoryRecursively(at: to)
                .map { String($0.path().dropFirst(baseUrlLength)) }
                .sorted()
            let expected = ["foo/bap", "foo/bar/baz/boop", "foo/bar/beep"]

            #expect(expected == results)
        }
    }
}
