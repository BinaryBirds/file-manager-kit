//
//  FileManagerKitTestSuite.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 01..
//

import FileManagerKitBuilder
import Foundation
import Testing

@testable import FileManagerKit

@Suite
struct FileManagerKitTestSuite {

    // MARK: - exists(at:) Tests

    @Test
    func exists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory(name: "foo") {
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
            Directory(name: "foo") {
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
            Directory(name: "foo") {
                Directory(name: "bar")
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
            Directory(name: "foo") {
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
            Directory(name: "foo") {
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
            Directory(name: "foo") {
                "bar"
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar")
            let dataToWrite = "data".data(using: .utf8)
            try $0.createFile(at: url, contents: dataToWrite)
            let data = $0.contents(atPath: url.path(percentEncoded: false))

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
            Directory(name: "foo") {
                Directory(name: "bar")
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
            Directory(name: "foo") {
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
            Directory(name: "foo")
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
            Directory(name: "a")
            Directory(name: "b")
            Directory(name: "c")
            File(name: ".foo", string: "foo")
            "bar"
            Link(name: "bar_link", target: "bar")
        }
        .test {
            let items = $0.listDirectory(at: $1).sorted()
            #expect(items == [".foo", "a", "b", "bar", "bar_link", "c"])
        }
    }

    @Test
    func listDirectory_whenDirectoryIsEmpty() throws {
        try FileManagerPlayground {
            Directory(name: "foo")
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

    @Test
    func listDirectory_whenDirectoryNameIsSpecial() throws {
        try FileManagerPlayground {
            Directory(name: "a a")
            Directory(name: "b b")
            Directory(name: "c c")
        }
        .test {
            let expectation = [
                "a a",
                "b b",
                "c c",
            ]
            let items = $0.listDirectory(at: $1).sorted()
            #expect(items == expectation)
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
            File(name: "sourceFile", string: "Hello, world!")
        }
        .test {
            let source = $1.appending(path: "sourceFile")
            let destination = $1.appending(path: "destination")
            try $0.softLink(from: source, to: destination)
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
                try $0.softLink(from: source, to: destination)
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
                try $0.softLink(from: source, to: destination)
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
            File(name: "file", string: text)
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
            Directory(name: "foo") {
                Directory(name: "bar") {
                    Directory(name: "baz") {
                        "boop"
                    }
                    "beep"
                }
                "bap"
            }
        }
        .test {
            let baseUrlLength = $1.path().count + 1
            let results = $0.listDirectoryRecursively(at: $1)
                .map { String($0.path().dropFirst(baseUrlLength)) }
                .sorted()
            let expected = [
                "foo/bap",
                "foo/bar/baz/boop",
                "foo/bar/beep",
            ]
            .sorted()
            #expect(expected == results)
        }
    }

    @Test
    func listDirectoryRecursivelyWithSpecialCharacters() throws {
        try FileManagerPlayground {
            Directory(name: "f oo") {
                Directory(name: "ba r") {
                    Directory(name: "b az") {
                        "bo op"
                    }
                    "bee p"
                }
                "b ap"
            }
        }
        .test {
            let baseUrlLength = $1.path().count + 1
            let results = $0.listDirectoryRecursively(at: $1)
                .map {
                    String(
                        $0.path(percentEncoded: false).dropFirst(baseUrlLength)
                    )
                }
                .sorted()
            let expected = [
                "f oo/b ap",
                "f oo/ba r/bee p",
                "f oo/ba r/b az/bo op",
            ]
            .sorted()

            #expect(expected == results)
        }
    }

    @Test
    func copyDirectoryRecursively() throws {
        try FileManagerPlayground {
            Directory(name: "from") {
                Directory(name: "foo") {
                    "bap"
                    Directory(name: "bar") {
                        "beep"
                        Directory(name: "baz") {
                            "boop"
                        }
                    }
                }
            }
            Directory(name: "to")
        }
        .test {
            let from = $1.appending(path: "from")
            let to = $1.appending(path: "to")

            try $0.copyRecursively(from: from, to: to)

            let baseUrlLength = to.path().count + 1
            let results = $0.listDirectoryRecursively(at: to)
                .map { String($0.path().dropFirst(baseUrlLength)) }
                .sorted()

            let expected = [
                "foo/bap",
                "foo/bar/baz/boop",
                "foo/bar/beep",
            ]
            .sorted()

            #expect(expected == results)
        }
    }

    @Test
    func copyDirectoryRecursivelyWithSpecialCharacters() throws {
        try FileManagerPlayground {
            Directory(name: "from") {
                Directory(name: "f oo") {
                    "bap"
                    Directory(name: "bar") {
                        "beep"
                        Directory(name: "baz") {
                            "boop"
                        }
                    }
                }
            }
            Directory(name: "to")
        }
        .test {
            let from = $1.appending(path: "from")
            let to = $1.appending(path: "to")

            try $0.copyRecursively(from: from, to: to)

            let baseUrlLength = to.path().count + 1
            let results = $0.listDirectoryRecursively(at: to)
                .map {
                    String(
                        $0.path(percentEncoded: false).dropFirst(baseUrlLength)
                    )
                }
                .sorted()
            let expected = [
                "f oo/bap",
                "f oo/bar/beep",
                "f oo/bar/baz/boop",
            ]
            .sorted()

            #expect(expected == results)
        }
    }

    @Test
    func extraParams() throws {
        let fileManager = FileManager.default
        let rootUrl = fileManager.temporaryDirectory
        let rootName = "test"

        try FileManagerPlayground(
            rootUrl: rootUrl,
            rootName: rootName,
            fileManager: fileManager
        ) {
            Directory(name: "from") {
                Directory(name: "foo") {
                    "bap"
                    Directory(name: "bar") {
                        "beep"
                        Directory(name: "baz") {
                            "boop"
                        }
                    }
                }
            }
            Directory(name: "to")
        }
        .test {
            #expect(
                $1.pathComponents
                    == rootUrl.appending(path: rootName).pathComponents
            )

            let from = $1.appending(path: "from")
            let to = $1.appending(path: "to")

            try $0.copyRecursively(from: from, to: to)

            let baseUrlLength = to.path().count + 1
            let results = $0.listDirectoryRecursively(at: to)
                .map { String($0.path().dropFirst(baseUrlLength)) }
                .sorted()
            let expected = [
                "foo/bap",
                "foo/bar/baz/boop",
                "foo/bar/beep",
            ]

            #expect(expected == results)
        }
    }

    @Test
    func buildAndRemove() throws {
        let playground = FileManagerPlayground {
            Directory(name: "foo") {
                File(name: "bar.txt", string: "baz")
            }
        }

        let built = try playground.build()
        let fileManager = built.0
        let builtURL = built.1

        let fileURL = builtURL.appending(path: "foo/bar")
            .appendingPathExtension("txt")

        #expect(fileManager.fileExists(atPath: fileURL.path()))

        try playground.remove()

        #expect(!fileManager.fileExists(atPath: builtURL.path()))
    }

    @Test
    func find() throws {
        try FileManagerPlayground {
            File(name: "fileA.txt", string: "Test")
            File(name: ".hidden.md", string: "Hidden")
            File(name: "readme.md", string: "Readme")
            Directory(name: "Subdir") {
                File(name: "nested.swift", string: "Nested")
            }
        }
        .test { fileManager, rootUrl in
            // Non-recursive, skip hidden
            let nonRecursive = fileManager.find(
                at: rootUrl
            )
            #expect(nonRecursive.contains("fileA.txt"))
            #expect(nonRecursive.contains("readme.md"))
            #expect(!nonRecursive.contains(".hidden.md"))
            #expect(!nonRecursive.contains("Subdir/nested.swift"))

            // Recursive, skip hidden
            let recursive = fileManager.find(
                recursively: true,
                at: rootUrl
            )
            #expect(recursive.contains("fileA.txt"))
            #expect(recursive.contains("readme.md"))
            #expect(recursive.contains("Subdir/nested.swift"))
            #expect(!recursive.contains(".hidden.md"))

            // Filter by name
            let named = fileManager.find(
                name: "readme",
                recursively: true,
                at: rootUrl
            )
            #expect(named.count == 1)
            #expect(named.first == "readme.md")

            // Filter by extension
            let mdFiles = fileManager.find(
                extensions: ["md"],
                recursively: true,
                skipHiddenFiles: false,
                at: rootUrl
            )
            #expect(mdFiles.contains("readme.md"))
            #expect(mdFiles.contains(".hidden.md"))

            // Filter by name and extension
            let combo = fileManager.find(
                name: "fileA",
                extensions: ["txt"],
                recursively: true,
                at: rootUrl
            )
            #expect(combo.contains("fileA.txt"))
        }
    }

    @Test
    func hardLink_whenSourceExists() throws {
        try FileManagerPlayground {
            File(name: "sourceFile", string: "Hello, hardlink!")
        }
        .test {
            let source = $1.appending(path: "sourceFile")
            let destination = $1.appending(path: "destination")

            try $0.hardLink(from: source, to: destination)

            #expect($0.fileExists(at: destination))
            let sourceAttributes = try $0.attributes(at: source)
            let destAttributes = try $0.attributes(at: destination)

            let sourceInode = sourceAttributes[.systemFileNumber] as? UInt64
            let destInode = destAttributes[.systemFileNumber] as? UInt64

            // Inode numbers should match for a true hard link
            #expect(sourceInode != nil && sourceInode == destInode)

            let sourceData = $0.contents(atPath: source.path())
            let destData = $0.contents(atPath: destination.path())
            #expect(sourceData == destData)
        }
    }

    @Test
    func size_whenDirectoryHasNestedFiles() throws {
        try FileManagerPlayground {
            Directory(name: "folder") {
                File(name: "a.txt", string: "12345")
                Directory(name: "subfolder") {
                    File(name: "b.txt", string: "abcde")
                }
            }
        }
        .test { fileManager, rootUrl in
            let folder = rootUrl.appending(path: "folder")
            let fileA = folder.appending(path: "a.txt")
            let fileB = folder.appending(path: "subfolder/b.txt")

            let aSize = try fileManager.size(at: fileA)
            let bSize = try fileManager.size(at: fileB)

            #expect(aSize == 5)
            #expect(bSize == 5)

            // due to file system differences, this won't be a perfect match
            let expectedSize = 10  // "12345".utf8.count + "abcde".utf8.count
            let reportedSize = try fileManager.size(at: folder)

            #expect(reportedSize >= expectedSize)
            // up to 128 KB buffer
            #expect(reportedSize < expectedSize + 128 * 1024)
        }
    }

}
