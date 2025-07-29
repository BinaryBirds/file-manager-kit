//
//  Directory.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

/// A `Buildable` representation of a directory in the file system.
///
/// The `Directory` type allows you to construct a directory with optional file attributes
/// and nested file system items using a result builder.
public struct Directory: Buildable {

    /// The name of the directory to create.
    let name: String
    /// The file attributes to apply to the directory, such as POSIX permissions.
    let attributes: [FileAttributeKey: Any]?
    /// The items contained within the directory, built using the `ItemBuilder` result builder.
    let contents: [FileManagerPlayground.Item]

    /// Creates a new directory with the specified name, optional attributes, and contents.
    ///
    /// - Parameters:
    ///   - name: The name of the directory.
    ///   - attributes: Optional file attributes such as permissions.
    ///   - builder: A result builder that defines the contents of the directory.
    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        @FileManagerPlayground.ItemBuilder _ builder: () ->
            [FileManagerPlayground.Item] = { [] }
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = builder()
    }

    /// Builds the directory and its contents at the specified location using the provided file manager.
    ///
    /// - Parameters:
    ///   - url: The URL where the directory should be created.
    ///   - fileManager: The file manager to use for file system operations.
    /// - Throws: An error if the directory or its contents could not be created.
    func build(
        at url: URL,
        using fileManager: FileManagerKit
    ) throws {
        let dirUrl = url.appending(path: name)
        try fileManager.createDirectory(
            at: dirUrl,
            attributes: attributes
        )

        for item in contents {
            try item.build(at: dirUrl, using: fileManager)
        }
    }
}
