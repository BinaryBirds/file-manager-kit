import Foundation
import Testing
@testable import FileManagerKit
import FileManagerKitTesting

@Suite(.serialized)
struct FileManagerKitTestSuite {
        
    // MARK: - exists(at:) Tests
    
    @Test
    func exists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            
            #expect(fileManager.exists(at: url))
        }
    }
    
    @Test
    func exists_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test {
            let url = URL(fileURLWithPath: "./does/not/exist")
            
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
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            
            #expect(fileManager.fileExists(at: url))
        }
    }
    
    @Test
    func fileExists_whenFolderExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            
            #expect(!fileManager.fileExists(at: url))
        }
    }
    
    @Test
    func fileExists_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test {
            let url = URL(fileURLWithPath: "./does/not/exist")
            
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
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo")
            
            #expect(fileManager.directoryExists(at: url))
        }
    }
    
    @Test
    func directoryExists_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            
            #expect(!fileManager.directoryExists(at: url))
        }
    }
    
    @Test
    func directoryExists_whenDirectoryDoesNotExist() throws {
        try FileManagerPlayground().test {
            let url = URL(fileURLWithPath: "./does/not/exist")
            
            #expect(!$0.directoryExists(at: url))
        }
    }
    
    // MARK: - createFile(at:) Tests
    
    @Test
    func createFile_whenCreatesFileSuccessfully() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./foo")
            try fileManager.createFile(at: url, contents: nil)
            
            #expect(fileManager.fileExists(at: url))
        }
    }
    
    @Test
    func createFile_whenIntermediateDirectoriesMissing() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar/baz")
            
            #expect(throws: CocoaError(.fileWriteUnknown), performing: {
                try fileManager.createFile(at: url, contents: nil)
            })
        }
    }
    
    @Test
    func createFile_whenFileAlreadyExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            let dataToWrite = "data".data(using: .utf8)
            try fileManager.createFile(at: url, contents: dataToWrite)
            let data = fileManager.contents(atPath: url.path())
            
            #expect(dataToWrite == data)
        }
    }
    
    // MARK: - createDirectory(at:) Tests
    
    @Test
    func createDirectory_whenCreatesDirectorySuccessfully() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./foo")
            try fileManager.createDirectory(at: url)
            
            #expect(fileManager.directoryExists(at: url))
        }
    }
    
    @Test
    func createDirectory_whenDirectoryAlreadyExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            try fileManager.createDirectory(at: url)
            
            #expect(fileManager.directoryExists(at: url))
        }
    }
    
    // MARK: - delete(at:) Tests
    
    @Test
    func delete_whenFileExists() throws {
        try FileManagerPlayground {
            Directory("foo") {
                "bar"
            }
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo/bar")
            try fileManager.delete(at: url)
            
            #expect(!fileManager.fileExists(at: url))
        }
    }
    
    @Test
    func delete_whenDirectoryExists() throws {
        try FileManagerPlayground {
            Directory("foo")
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./foo")
            try fileManager.delete(at: url)
            
            #expect(!fileManager.directoryExists(at: url))
        }
    }
    
    @Test
    func delete_whenDirectoryDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./foo")
            
            do {
                try fileManager.delete(at: url)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let cwd = URL(string: ".")!
            let items = fileManager.listDirectory(at: cwd).sorted()
            #expect(items == [".foo", "a", "b", "bar", "bar_link", "c"])
        }
    }
    
    @Test
    func listDirectory_whenDirectoryIsEmpty() throws {
        try FileManagerPlayground {
            Directory("foo")
        }.test {
            let url = URL(fileURLWithPath: "./foo")
            let items = $0.listDirectory(at: url)
            #expect(items == [])
        }
    }
    
    @Test
    func listDirectory_whenPathIsNotDirectory() throws {
        try FileManagerPlayground {
            "foo"
        }.test {
            let url = URL(fileURLWithPath: "./foo")
            let items = $0.listDirectory(at: url)
            #expect(items == [])
        }
    }
    
    // MARK: - copy(from:to:) Tests

    @Test
    func copy_whenSourceExists() throws {
        try FileManagerPlayground {
            "source"
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./source")
            let destination = URL(fileURLWithPath: "./destination")

            try fileManager.copy(from: source, to: destination)

            #expect(fileManager.fileExists(at: destination))
            let originalData = fileManager.contents(atPath: source.path())
            let copiedData = fileManager.contents(atPath: destination.path())
            #expect(originalData == copiedData)
        }
    }

    @Test
    func copy_whenSourceDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let source = URL(fileURLWithPath: "./nonexistent")
            let destination = URL(fileURLWithPath: "./destination")

            do {
                try fileManager.copy(from: source, to: destination)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./source")
            let destination = URL(fileURLWithPath: "./destination")

            do {
                try fileManager.copy(from: source, to: destination)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./source")
            let destination = URL(fileURLWithPath: "./destination")

            try fileManager.move(from: source, to: destination)

            #expect(!fileManager.fileExists(at: source))
            #expect(fileManager.fileExists(at: destination))
        }
    }

    @Test
    func move_whenSourceDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let source = URL(fileURLWithPath: "./nonexistent")
            let destination = URL(fileURLWithPath: "./destination")

            do {
                try fileManager.move(from: source, to: destination)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./source")
            let destination = URL(fileURLWithPath: "./destination")

            do {
                try fileManager.move(from: source, to: destination)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./sourceFile")
            let destination = URL(fileURLWithPath: "./destination")
            try fileManager.link(from: source, to: destination)
            let exists = fileManager.exists(at: destination)
            let attributes = try fileManager.attributes(at: destination)
            let fileType = attributes[.type] as? FileAttributeType

            #expect(fileManager.linkExists(at: destination))
            #expect(exists)
            #expect(fileType == .typeSymbolicLink)
        }
    }

    @Test
    func link_whenSourceDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let source = URL(fileURLWithPath: "./missingSource")
            let destination = URL(fileURLWithPath: "./destination")
            try fileManager.link(from: source, to: destination)
            let attributes = try fileManager.attributes(at: destination)
            let fileType = attributes[.type] as? FileAttributeType

            #expect(fileType == .typeSymbolicLink)

            #expect(fileManager.linkExists(at: destination))

            
            // Check that resolving the symlink gives the expected (absolute) path
            let resolvedPath = try fileManager.destinationOfSymbolicLink(atPath: destination.path())
            #expect(URL(fileURLWithPath: resolvedPath).lastPathComponent == source.lastPathComponent)

            // Check that the target file does not exist (dangling link)
            #expect(!fileManager.fileExists(atPath: resolvedPath))
        }
    }

    @Test
    func link_whenDestinationAlreadyExists() throws {
        try FileManagerPlayground {
            "source"
            "destination"
        }.test { fileManager in
            let source = URL(fileURLWithPath: "./source")
            let destination = URL(fileURLWithPath: "./destination")

            do {
                try fileManager.link(from: source, to: destination)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let file = URL(fileURLWithPath: "./file")

            let creationDate = try fileManager.creationDate(at: file)
            let attributes = try fileManager.attributesOfItem(atPath: file.path())

            #expect(creationDate == (attributes[.creationDate] as? Date ?? attributes[.modificationDate] as! Date))
        }
    }

    @Test
    func creationDate_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let file = URL(fileURLWithPath: "./nonexistent")

            do {
                _ = try fileManager.creationDate(at: file)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let file = URL(fileURLWithPath: "./file")

            let modificationDate = try fileManager.modificationDate(at: file)
            let attributes = try fileManager.attributesOfItem(atPath: file.path())

            #expect(modificationDate == attributes[.modificationDate] as? Date)
        }
    }

    @Test
    func modificationDate_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let file = URL(fileURLWithPath: "./nonexistent")

            do {
                _ = try fileManager.modificationDate(at: file)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let file = URL(fileURLWithPath: "./file")

            let fileSize = try fileManager.size(at: file)
            let expectedSize = "Hello, world!".utf8.count

            #expect(fileSize == expectedSize)
        }
    }

    @Test
    func size_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let file = URL(fileURLWithPath: "./nonexistent")
            let size = try fileManager.size(at: file)
            
            #expect(size == 0)
        }
    }
    
    // MARK: - setAttributes(at:attributes:) Tests

    @Test
    func setAttributes_whenFileExists() throws {
        try FileManagerPlayground {
            "file"
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./file")

            let newDate = Date(timeIntervalSince1970: 10000)
            let attributes: [FileAttributeKey: Any] = [
                .modificationDate: newDate
            ]
            try fileManager.setAttributes(attributes, at: url)
            let updatedAttributes = try fileManager.attributes(at: url)

            #expect(updatedAttributes[.modificationDate] as? Date == newDate)
        }
    }

    @Test
    func setAttributes_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./nonexistent")

            do {
                let attributes: [FileAttributeKey: Any] = [.modificationDate: Date()]
                try fileManager.setAttributes(attributes, at: url)
                #expect(Bool(false))
            } catch let error as NSError {
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
        }.test { fileManager in
            let url = URL(fileURLWithPath: "./file")

            let permissions = 600
            try fileManager.setPermissions(permissions, at: url)
            let updatedPermissions = try fileManager.permissions(at: url)

            #expect(updatedPermissions == permissions)
        }
    }

    @Test
    func setPermissions_whenFileDoesNotExist() throws {
        try FileManagerPlayground().test { fileManager in
            let url = URL(fileURLWithPath: "./nonexistent")

            do {
                try fileManager.setPermissions(600, at: url)
                #expect(Bool(false))
            } catch let error as NSError {
                #expect(error.domain == NSCocoaErrorDomain)
                #expect(error.code == 4)
            }
        }
    }
}
