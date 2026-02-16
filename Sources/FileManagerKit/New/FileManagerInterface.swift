//
//  File.swift
//  file-manager-kit
//
//  Created by Tibor Bödecs on 2026. 02. 16..
//

import SystemPackage

public protocol FileManagerInterface: Sendable {

    func exists(
        at path: FilePath
    ) async throws -> Bool
}
