//
//  Link.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

/// A `Buildable` representation of a file system link, either symbolic or hard.
///
/// The `Link` type allows you to define a link with a name, a target path, and the link type.
public struct Link: Buildable {

    /// The name of the link to be created.
    let name: String
    /// The target path that the link points to, relative to the link's location.
    let target: String
    /// Indicates whether the link is symbolic (`true`) or a hard link (`false`).
    let isSymbolic: Bool

    /// Creates a new link with the specified name, target, and link type.
    ///
    /// - Parameters:
    ///   - name: The name of the link to create.
    ///   - target: The relative target path the link should point to.
    ///   - isSymbolic: Whether to create a symbolic link (`true`, default) or hard link (`false`).
    public init(
        name: String,
        target: String,
        isSymbolic: Bool = true
    ) {
        self.name = name
        self.target = target
        self.isSymbolic = isSymbolic
    }

    /// Builds the link at the specified location using the provided file manager.
    ///
    /// - Parameters:
    ///   - url: The URL where the link should be created.
    ///   - fileManager: The file manager used to create the link.
    /// - Throws: An error if the link could not be created.
    func build(
        at url: URL,
        using fileManager: FileManagerKit
    ) throws {
        let linkUrl = url.appending(path: name)
        let targetUrl = url.appending(path: target)
        if isSymbolic {
            try fileManager.softLink(from: targetUrl, to: linkUrl)
        }
        else {
            try fileManager.hardLink(from: targetUrl, to: linkUrl)
        }
    }
}
