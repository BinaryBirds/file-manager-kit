#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Testing
@testable import FileManagerKit

@Suite
struct FileManagerKitTestSuite {

    @Test
    func urlPolyfills() throws {
        let url1 = URL(filePath: "/foo").appending(path: "bar")
        #expect(url1.path() == "/foo/bar")
    }
    
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
        
        print(fileManager.listDirectory(at: workUrl))
    }
}
