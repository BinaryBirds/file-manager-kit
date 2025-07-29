//
//  JSON.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import FileManagerKit
import FileManagerKitBuilder
import Foundation

/// A `BuildableItem` that generates a `.json` file from any `Encodable` type.
///
/// This type encodes the provided Swift value to JSON using `JSONEncoder` with pretty-printed and sorted key formatting,
/// and produces a file system representation suitable for use in a `FileManagerPlayground`.
public struct JSON<T: Encodable>: BuildableItem {

    /// The base name of the JSON file (without extension).
    public let name: String
    /// The file extension, defaulting to `"json"`.
    public let ext: String
    /// The `Encodable` value that will be serialized to JSON.
    public let contents: T

    /// Creates a new `JSON` buildable item.
    ///
    /// - Parameters:
    ///   - name: The base name of the JSON file.
    ///   - ext: The file extension (defaults to `"json"`).
    ///   - contents: The value to encode to JSON.
    public init(
        name: String,
        ext: String = "json",
        contents: T
    ) {
        self.name = name
        self.ext = ext
        self.contents = contents
    }

    /// Builds a `FileManagerPlayground.Item.file` from the encoded JSON contents.
    ///
    /// - Returns: A file representation containing the encoded JSON.
    public func buildItem() -> FileManagerPlayground.Item {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
        ]

        let data = try! encoder.encode(contents)
        let string = String(data: data, encoding: .utf8)!

        return .file(
            .init(
                name: "\(name).\(ext)",
                string: string
            )
        )
    }
}
