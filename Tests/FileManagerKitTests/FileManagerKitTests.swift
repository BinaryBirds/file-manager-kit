import XCTest

@testable import FileManagerKit

final class FileManagerKitTests: XCTestCase {

    func testURLPolyfills() throws {

        let url1 = URL(filePath: "/foo").appending(path: "bar")
        XCTAssertEqual(url1.path(), "/foo/bar")
    }
}
