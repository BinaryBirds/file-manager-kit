//
//  FileManagerKitTestSuite.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 01..
//

import Testing
import SystemPackage

@testable import FileManagerKit

@Suite
struct FileManagerTestSuite {
    
    // MARK: - exists(at:) Tests

    @Test(
        arguments: [
            NIOFileManager(),
            FoundationFileManager(),
        ] as [FileManagerInterface]
    )
    func fileNotExists(
        fileManager: FileManagerInterface
    ) async throws {
        let exists = try await fileManager.exists(at: "/asdf/asdf/asdf")
        #expect(!exists)       
    }
}
