//
//  Buildable.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

/// A protocol that defines the ability to create or assemble resources at a given file system path.
///
/// Types conforming to `Buildable` implement the `build(at:using:)` method, which is responsible
/// for constructing a file system hierarchy or resources at the specified location using a given file manager.
protocol Buildable {

    /// Builds the conforming item at the specified file system location using the provided file manager.
    ///
    /// - Parameters:
    ///   - path: The location where the item should be built.
    ///   - fileManager: The file manager instance used to perform file system operations.
    /// - Throws: An error if the build process fails.
    func build(
        at path: URL,
        using fileManager: FileManagerKit
    ) throws
}
