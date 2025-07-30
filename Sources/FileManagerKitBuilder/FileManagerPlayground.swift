//
//  FileManagerPlayground.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

/// A utility type for creating, testing, and cleaning up temporary file system hierarchies using `FileManager`.
///
/// This struct enables developers to declaratively define file structures using a builder DSL and run tests
/// against them in isolation.
public struct FileManagerPlayground {

    /// Represents a buildable file system item used within a `FileManagerPlayground` hierarchy.
    ///
    /// Each case corresponds to a file, directory, or symbolic/hard link.
    public enum Item: Buildable {
        case file(File)
        case directory(Directory)
        case link(Link)

        func build(
            at path: URL,
            using fileManager: FileManagerKit
        ) throws {
            switch self {
            case .file(let file):
                try file.build(at: path, using: fileManager)
            case .directory(let dir):
                try dir.build(at: path, using: fileManager)
            case .link(let link):
                try link.build(at: path, using: fileManager)
            }
        }
    }

    /// A result builder that produces an array of `Item` values from DSL-style syntax.
    @resultBuilder
    public enum ItemBuilder {

        /// Converts a single `BuildableItem` into a `FileManagerPlayground.Item`.
        ///
        /// - Parameter expression: A type conforming to `BuildableItem`.
        /// - Returns: An array containing one `Item` built from the input.
        public static func buildExpression<T: BuildableItem>(
            _ expression: T
        )
            -> [Item]
        {
            [
                expression.buildItem()
            ]
        }

        /// Converts an array of `BuildableItem`s into an array of `Item`s.
        ///
        /// - Parameter expressions: An array of `BuildableItem` types.
        /// - Returns: An array of built items.
        public static func buildExpression<T: BuildableItem>(
            _ expressions: [T]
        )
            -> [Item]
        {
            expressions.map {
                $0.buildItem()
            }
        }

        /// Combines multiple `Item` arrays into a single array.
        ///
        /// - Parameter components: Variadic item arrays to flatten.
        /// - Returns: A single flat array of items.
        public static func buildBlock(
            _ components: [Item]...
        ) -> [Item] {
            components.flatMap { $0 }
        }

        /// Wraps a specific `Buildable` item type into a corresponding `Item` case.
        ///
        /// - Parameter expression: A file/directory/link object.
        /// - Returns: An array containing one wrapped item.
        public static func buildExpression(
            _ expression: File
        ) -> [Item] {
            [
                .file(expression)
            ]
        }

        /// Wraps a specific `Buildable` item type into a corresponding `Item` case.
        ///
        /// - Parameter expression: A file/directory/link object.
        /// - Returns: An array containing one wrapped item.
        public static func buildExpression(
            _ expression: Directory
        ) -> [Item] {
            [
                .directory(expression)
            ]
        }

        /// Wraps a specific `Buildable` item type into a corresponding `Item` case.
        ///
        /// - Parameter expression: A file/directory/link object.
        /// - Returns: An array containing one wrapped item.
        public static func buildExpression(
            _ expression: Link
        ) -> [Item] {
            [
                .link(expression)
            ]
        }

        /// Treats a string literal as a file with no contents.
        ///
        /// - Parameter expression: The string name of the file.
        /// - Returns: An array with a `.file` item.
        public static func buildExpression(
            _ expression: String
        ) -> [Item] {
            [
                .file(
                    .init(name: expression, contents: nil)
                )
            ]
        }

        /// Passes through a pre-constructed array of items.
        ///
        /// - Parameter expression: An array of items.
        /// - Returns: The same array.
        public static func buildExpression(
            _ expression: [Item]
        ) -> [Item] {
            expression
        }

        /// Supports conditional branches and optional item blocks in the builder.
        ///
        /// - Parameter component: Conditional or optional content branches.
        /// - Returns: The resolved item array.
        public static func buildOptional(
            _ component: [Item]?
        ) -> [Item] {
            component ?? []
        }

        /// Supports conditional branches and optional item blocks in the builder.
        ///
        /// - Parameter component: Conditional or optional content branches.
        /// - Returns: The resolved item array.
        public static func buildEither(
            first component: [Item]
        ) -> [Item] {
            component
        }

        /// Supports conditional branches and optional item blocks in the builder.
        ///
        /// - Parameter component: Conditional or optional content branches.
        /// - Returns: The resolved item array.
        public static func buildEither(
            second component: [Item]
        ) -> [Item] {
            component
        }

        /// Supports conditional branches and optional item blocks in the builder.
        ///
        /// - Parameter components: Conditional or optional content branches.
        /// - Returns: The resolved item array.
        public static func buildArray(
            _ components: [[Item]]
        ) -> [Item] {
            components.flatMap { $0 }
        }
    }

    /// The file manager instance used for file system operations.
    private let fileManager: FileManager

    /// The root `Directory` object representing the file structure to be built.
    private let directory: Directory

    /// The base URL at which the root directory will be created.
    private let rootUrl: URL

    /// The full URL of the playground directory where the file structure will reside.
    public let playgroundDirUrl: URL

    /// Initializes a new `FileManagerPlayground` instance with a root directory and file structure.
    ///
    /// - Parameters:
    ///   - rootUrl: Optional base path to build the playground in. Defaults to a temporary directory.
    ///   - rootName: Optional root folder name. Defaults to a unique name.
    ///   - fileManager: The file manager instance to use for operations.
    ///   - builder: A DSL block that defines the file system structure.
    public init(
        rootUrl: URL? = nil,
        rootName: String? = nil,
        fileManager: FileManager = .default,
        @ItemBuilder _ builder: () -> [Item] = { [] }
    ) {
        self.fileManager = fileManager
        self.rootUrl = rootUrl ?? self.fileManager.temporaryDirectory
        self.directory = .init(
            name: rootName ?? "FileManagerPlayground_\(UUID().uuidString)",
            builder
        )
        self.playgroundDirUrl = self.rootUrl.appending(path: directory.name)
    }

    /// Builds the file hierarchy in the file system using the specified root and file manager.
    ///
    /// - Returns: A tuple of the file manager and the root URL where the structure was created.
    /// - Throws: An error if the structure could not be built.
    @discardableResult
    public func build() throws -> (FileManager, URL) {
        try directory.build(at: rootUrl, using: fileManager)
        return (fileManager, playgroundDirUrl)
    }

    /// Removes the root directory created by the playground, if it exists.
    ///
    /// - Returns: A tuple of the file manager and the root URL that was deleted (if any).
    /// - Throws: An error if the directory could not be removed.
    @discardableResult
    public func remove() throws -> (FileManager, URL) {
        if fileManager.exists(at: playgroundDirUrl) {
            try fileManager.delete(at: playgroundDirUrl)
        }
        return (fileManager, playgroundDirUrl)
    }

    /// Builds the hierarchy, runs a test block, and ensures the playground directory is deleted afterward.
    ///
    /// - Parameter testBlock: A block receiving the file manager and root URL to run assertions against.
    /// - Throws: Any error thrown by the test block or file system operations.
    public func test(
        _ testBlock: (FileManager, URL) throws -> Void
    ) throws {
        try directory.build(at: rootUrl, using: fileManager)
        try testBlock(fileManager, playgroundDirUrl)
        try fileManager.delete(at: playgroundDirUrl)
    }
}
