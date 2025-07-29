//
//  File.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

/// A `Buildable` representation of a file in the file system.
///
/// The `File` type allows you to define the name, optional attributes, and contents of a file.
public struct File: ExpressibleByStringLiteral, Buildable {

    /// The name of the file to be created.
    let name: String
    /// Optional file attributes, such as POSIX permissions.
    let attributes: [FileAttributeKey: Any]?
    /// Optional data content to be written into the file.
    let contents: Data?

    /// Creates a new file with the given name, optional attributes, and binary contents.
    ///
    /// - Parameters:
    ///   - name: The name of the file.
    ///   - attributes: Optional file attributes.
    ///   - contents: Optional data to write into the file.
    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        contents: Data? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contents
    }

    /// Creates a new file with a UTF-8 encoded string as contents.
    ///
    /// - Parameters:
    ///   - name: The name of the file.
    ///   - attributes: Optional file attributes.
    ///   - string: Optional string content to encode and write into the file.
    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        string: String? = nil
    ) {
        self.init(
            name: name,
            attributes: attributes,
            contents: string?.data(using: .utf8)
        )
    }

    /// Initializes a file from a string literal, using the literal as the file name and no contents.
    ///
    /// - Parameter value: The name of the file.
    public init(
        stringLiteral value: String
    ) {
        self.init(name: value, string: nil)
    }

    /// Builds the file at the specified location using the provided file manager.
    ///
    /// - Parameters:
    ///   - url: The URL where the file should be created.
    ///   - fileManager: The file manager used to perform file system operations.
    /// - Throws: An error if the file could not be created.
    func build(
        at url: URL,
        using fileManager: FileManagerKit
    ) throws {
        try fileManager.createFile(
            at: url.appending(path: name),
            contents: contents,
            attributes: attributes
        )
    }
}
