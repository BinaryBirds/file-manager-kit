//
//  File.swift
//  file-manager-kit
//
//  Created by Tibor Bödecs on 2026. 02. 16..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SystemPackage

public struct FoundationFileManager: @unchecked Sendable {
    
    private let fileManager: Foundation.FileManager
    
    public init(
        _ fileManager: Foundation.FileManager = .default
    ) {
        self.fileManager = fileManager
    }
}

extension FoundationFileManager: FileManagerInterface {
    
    public func exists(
        at path: FilePath
    ) async throws -> Bool {
        fileManager.fileExists(atPath: path.string)
    }
}
