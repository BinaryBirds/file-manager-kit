//
//  File.swift
//  file-manager-kit
//
//  Created by Tibor Bödecs on 2026. 02. 16..
//

import _NIOFileSystem

public struct NIOFileManager {
    
    private let fileSystem: FileSystem
    
    public init(
        _ fileSystem: FileSystem = .shared
    ) {
        self.fileSystem = fileSystem
    }
}

extension NIOFileManager: FileManagerInterface {
    
    public func exists(
        at path: FilePath
    ) async throws -> Bool {
        if let _ = try await fileSystem.info(forFileAt: path) {
            return true
        }
        return false
    }
}

