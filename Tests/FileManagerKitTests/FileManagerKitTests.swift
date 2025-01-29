import Foundation
import Testing
@testable import FileManagerKit

@Suite()
struct FileManagerKitTestSuite {
    
    // TODO: where does this belong to?
    
    @Test
    func listDirectory() throws {
        let fileManager = FileManager.default
        
        let tmpUrl = fileManager.temporaryDirectory
        let workUrl = tmpUrl.appending(path: UUID().uuidString)
        try fileManager.createDirectory(at: workUrl)
        
        let aUrl = workUrl.appending(path: "a")
        try fileManager.createDirectory(at: aUrl)
        
        let bUrl = workUrl.appending(path: "b")
        try fileManager.createDirectory(at: bUrl)
        
        let cUrl = workUrl.appending(path: "c")
        try fileManager.createDirectory(at: cUrl)
        
        let fooUrl = workUrl.appending(path: ".foo")
        try "foo".write(to: fooUrl, atomically: true, encoding: .utf8)
        
        let fooInAUrl = aUrl.appending(path: ".foo")
        try "fooInA".write(to: fooInAUrl, atomically: true, encoding: .utf8)
        
        let items = fileManager.listDirectory(at: workUrl)
        #expect(items == ["a", ".foo", "c", "b"])
    }
    
//    let fileManager: FileManagerKit = MockFileManager()
    let fileManager: FileManagerKit = FileManager.default
    
    let fileUrl = URL(string: "/path/to/file")!
    let folderUrl = URL(string: "/path/to/folder")!
    let pathToNonExistentFile = URL(string: "/path/to/nonexistent")!
    let data = Data("Hello".utf8)
    
    // MARK: - exists(at:) Tests

    @Test
    func testExists_whenFileExists() throws {
        do {
            try fileManager.createFile(at: fileUrl, contents: data)
            
        }
        catch {
            print("????????")
            print(error)
            print(error)
        }
        #expect(fileManager.exists(at: fileUrl))
    }
    
    @Test
    func testExists_whenFileDoesNotExist() throws {
        #expect(!fileManager.exists(at: pathToNonExistentFile))
    }
    
    // MARK: - fileExists(at:) Tests

    @Test
    func testFileExists_whenFileExists() throws {
        try fileManager.createFile(at: fileUrl, contents: data)
        #expect(fileManager.fileExists(at: fileUrl))
    }

    @Test
    func testFileExists_whenPathIsFolder() throws {
        try fileManager.createDirectory(at: folderUrl)
        #expect(!fileManager.fileExists(at: folderUrl))
    }

    @Test
    func testFileExists_whenFileDoesNotExist() throws {
        #expect(!fileManager.fileExists(at: fileUrl))
    }
    
    // MARK: - directoryExists(at:) Tests
    
    @Test
    func testDirectoryExists_whenDirectoryExists() throws {
        try fileManager.createDirectory(at: folderUrl)
        #expect(fileManager.directoryExists(at: folderUrl))
    }

    @Test
    func testDirectoryExists_whenPathIsFile() throws {
        try fileManager.createFile(at: fileUrl, contents: data)
        #expect(!fileManager.directoryExists(at: fileUrl))
    }

    @Test
    func testDirectoryExists_whenDirectoryDoesNotExist() throws {
        #expect(!fileManager.directoryExists(at: folderUrl))
    }
    
    // MARK: - createFile(at:) Tests
    
    @Test
    func testCreateFile_whenCreatesFileSuccessfully() throws {
        try fileManager.createFile(at: fileUrl, contents: data)
        #expect(fileManager.fileExists(at: fileUrl))
    }

    @Test
    func testCreateFile_whenFileAlreadyExists() throws {
        try fileManager.createFile(at: fileUrl, contents: data)

        #expect(throws: MockFileManager.Error.itemAlreadyExists, performing: {
            try fileManager.createFile(at: fileUrl, contents: data)
        })
        #expect(performing: {
            try fileManager.createFile(at: fileUrl, contents: data)
        }, throws: { error in
            #expect(error is NSError)
            return true
            
            // TODO: check error
        })
//        #expect(throws: NSError) {
//            try fileManager.createFile(at: fileUrl, contents: data)
//        }
        
//        XCTAssertThrowsError(try mockFileManager.createFile(at: fileURL, contents: Data("World".utf8))) { error in
//            XCTAssertEqual((error as NSError).code, 516) // File exists
//        }
    }
    
    // MARK: - createDirectory(at:) Tests

    @Test
    func testCreateDirectory_whenCreatesDirectorySuccessfully() throws {
        try fileManager.createDirectory(at: folderUrl)
        #expect(fileManager.directoryExists(at: folderUrl))
    }

    @Test
    func testCreateDirectory_whenDirectoryAlreadyExists() throws {
        try fileManager.createDirectory(at: folderUrl)

        #expect(performing: {
            try fileManager.createDirectory(at: folderUrl)
        }, throws: { error in
            #expect(error is NSError)
            return true
            
            // TODO: check error
        })
//        XCTAssertThrowsError() { error in
//            XCTAssertEqual((error as NSError).code, 516) // Directory exists
//        }
    }
    
    // MARK: - delete(at:) Tests

    @Test
    func testDelete_whenFileExists() throws {
        try fileManager.createFile(at: fileUrl, contents: data)

        try fileManager.delete(at: fileUrl)
        #expect(!fileManager.fileExists(at: fileUrl))
    }

    @Test
    func testDelete_whenDirectoryExists() throws {
        try fileManager.createDirectory(at: folderUrl)
        try fileManager.delete(at: folderUrl)
        #expect(!fileManager.directoryExists(at: folderUrl))
    }

    @Test
    func testDelete_whenPathDoesNotExist() throws {
        try fileManager.createDirectory(at: folderUrl)

        #expect(performing: {
            try fileManager.delete(at: pathToNonExistentFile)
        }, throws: { error in
            #expect(error is NSError)
            return true
            
            // TODO: check error
        })
//        XCTAssertThrowsError() { error in
//            XCTAssertEqual((error as NSError).code, 4) // File not found
//        }
    }
    
    // MARK: - listDirectory(at:) Tests

    @Test
    func testListDirectory() throws {
        try fileManager.createDirectory(at: folderUrl)
        let file1Url = folderUrl.appendingPathComponent("file1.txt")
        let file2Url = folderUrl.appendingPathComponent("file2.txt")
        try fileManager.createFile(at: file1Url, contents: Data("File1".utf8))
        try fileManager.createFile(at: file2Url, contents: Data("File2".utf8))
        let items = fileManager.listDirectory(at: folderUrl)
        #expect(items.sorted() == ["file1.txt", "file2.txt"].sorted())
    }

    @Test
    func testListDirectory_whenDirectoryIsEmpty() throws {
        try fileManager.createDirectory(at: folderUrl)
        let items = fileManager.listDirectory(at: folderUrl)
        #expect(items == [])
    }

    @Test
    func testListDirectory_whenPathIsNotDirectory() throws {
        try fileManager.createFile(at: fileUrl, contents: data)
        let items = fileManager.listDirectory(at: fileUrl)
        #expect(items == [])
    }
}
