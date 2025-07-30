//
//  BuildableItem.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

/// A protocol that defines an item that can be represented as a `FileManagerPlayground.Item`.
///
/// Types conforming to this protocol can convert themselves into a file system representation,
/// which can then be used to build a file hierarchy using the `FileManagerPlayground`.
public protocol BuildableItem {

    /// Creates a `FileManagerPlayground.Item` representation of the conforming instance.
    ///
    /// - Returns: A value representing the file system item.
    func buildItem() -> FileManagerPlayground.Item
}
