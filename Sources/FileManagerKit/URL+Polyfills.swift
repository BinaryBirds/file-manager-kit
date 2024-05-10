//
//  URL+Polyfills.swift
//  FileManagerKit
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import class Foundation.FileManager
import struct Foundation.URL
import struct Foundation.URLComponents

// Derived from: https://github.com/gwynne/swift-api-polyfills

#if !canImport(Darwin)

extension Foundation.URL {

    public enum DirectoryHint: Hashable {
        /// Specifies that the `URL` does reference a directory.
        case isDirectory

        /// Specifies that the `URL` does **not** reference a directory.
        case notDirectory

        /// Specifies that `URL` should check with the file system to determine whether it references a directory.
        case checkFileSystem

        /// Specifies that `URL` should infer whether is references a directory based on whether it has a trialing slash.
        case inferFromPath

        fileprivate func isDirectoryParam(for path: some StringProtocol) -> Bool
        {
            switch self {
            case .isDirectory: true
            case .notDirectory: false
            case .checkFileSystem:
                path.starts(with: "/")
                    && ((try? URL(
                        filePath: String(path),
                        directoryHint: .notDirectory
                    )
                    .resourceValues(forKeys: [.isDirectoryKey]))?
                    .isDirectory ?? false)
            case .inferFromPath:
                #if os(Windows)
                path.hasSuffix("\\")
                #else
                path.hasSuffix("/")
                #endif
            }
        }
    }

    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path
    /// component of the URL; otherwise it returns an empty string.
    ///
    /// > Note: This function will resolve against the base `URL`.
    ///
    /// - Parameter percentEncoded: whether the path should be percent encoded, defaults to `true`.
    /// - Returns: the path component of the URL.
    public func path(percentEncoded: Bool = true) -> String {
        (percentEncoded
            ? path.addingPercentEncoding(
                withAllowedCharacters: .urlPathAllowed
            ) : path) ?? "/"
    }

    /// Initializes a newly created file URL referencing the local file or directory at path, relative to a base URL.
    ///
    /// If an empty string is used for the path, then the path is assumed to be ".".
    public init(
        filePath path: String,
        directoryHint: DirectoryHint = .inferFromPath,
        relativeTo base: URL? = nil
    ) {
        if directoryHint == .checkFileSystem {
            self.init(fileURLWithPath: path, relativeTo: base)
        }
        else {
            self.init(
                fileURLWithPath: path,
                isDirectory: directoryHint.isDirectoryParam(for: path),
                relativeTo: base
            )
        }
    }

    /// Returns a URL constructed by appending the given path to self.
    ///
    /// - Parameters:
    ///   - path: The path to add
    ///   - directoryHint: A hint to whether this URL will point to a directory
    /// - Returns: The new URL
    public func appending(
        path: some StringProtocol,
        directoryHint hint: DirectoryHint = .inferFromPath
    ) -> URL {
        hint == .checkFileSystem
            ? appendingPathComponent(.init(path))
            : appendingPathComponent(
                .init(path),
                isDirectory: hint.isDirectoryParam(for: path)
            )
    }

    /// Appends a path to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public mutating func append(
        path: some StringProtocol,
        directoryHint hint: DirectoryHint = .inferFromPath
    ) {
        hint == .checkFileSystem
            ? appendPathComponent(.init(path))
            : appendPathComponent(
                .init(path),
                isDirectory: hint.isDirectoryParam(for: path)
            )
    }

    /// Returns a URL constructed by appending the given path component to self.
    ///
    /// The path component is first percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    /// - Returns: The new URL
    public func appending(
        component: some StringProtocol,
        directoryHint hint: DirectoryHint = .inferFromPath
    ) -> URL {
        hint == .checkFileSystem
            ? appendingPathComponent(.init(component))
            : appendingPathComponent(
                .init(component),
                isDirectory: hint.isDirectoryParam(for: component)
            )
    }

    /// Appends a path component to the receiver.
    ///
    /// The path component is first percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append(
        component: some StringProtocol,
        directoryHint hint: DirectoryHint = .inferFromPath
    ) {
        hint == .checkFileSystem
            ? appendPathComponent(.init(component))
            : appendPathComponent(
                .init(component),
                isDirectory: hint.isDirectoryParam(for: component)
            )
    }

    /// Returns a URL constructed by appending the given varidic list of path components to self.
    ///
    /// - Parameters:
    ///   - components: The list of components to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    /// - Returns: The new URL
    public func appending<S>(
        components: S...,
        directoryHint: DirectoryHint = .inferFromPath
    ) -> URL where S: StringProtocol {
        guard !components.isEmpty else {
            return self
        }

        let almost = components.dropLast()
            .reduce(self) {
                $0.appendingPathComponent(.init($1), isDirectory: true)
            }

        return directoryHint == .checkFileSystem
            ? almost.appendingPathComponent(.init(components.last!))
            : almost.appendingPathComponent(
                .init(components.last!),
                isDirectory: directoryHint.isDirectoryParam(
                    for: components.last!
                )
            )
    }

    /// Appends a varidic list of path components to the URL.
    ///
    /// - Parameters:
    ///   - components: The list of components to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append<S>(
        components: S...,
        directoryHint: DirectoryHint = .inferFromPath
    ) where S: StringProtocol {
        guard !components.isEmpty else {
            return
        }

        _ = components.dropLast()
            .reduce(into: self) {
                $0.appendPathComponent(.init($1), isDirectory: true)
            }

        directoryHint == .checkFileSystem
            ? appendPathComponent(.init(components.last!))
            : appendPathComponent(
                .init(components.last!),
                isDirectory: directoryHint.isDirectoryParam(
                    for: components.last!
                )
            )
    }

    // MARK: -

    /// The working directory of the current process.
    ///
    /// Calling this property will issue a `getcwd` syscall.
    public static func currentDirectory() -> URL {
        self.init(
            filePath: FileManager.default.currentDirectoryPath,
            directoryHint: .isDirectory
        )
    }

    /// The home directory for the current user (`~/`).
    ///
    /// Complexity: O(1)
    public static var homeDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
    }

    /// The temporary directory for the current user.
    ///
    /// Complexity: O(1)
    public static var temporaryDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    /// Discardable cache files directory for the current user (~/Library/Caches).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var cachesDirectory: URL {
        try! self.init(for: .cachesDirectory, in: .userDomainMask, create: true)
    }

    /// Supported applications (/Applications).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var applicationDirectory: URL {
        try! self.init(
            for: .applicationDirectory,
            in: .localDomainMask,
            create: true
        )
    }

    /// Various user-visible documentation, support, and configuration files for the current user (~/Library).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var libraryDirectory: URL {
        try! self.init(
            for: .libraryDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// User home directories (/Users).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var userDirectory: URL {
        try! self.init(
            for: .userDirectory,
            in: .localDomainMask,
            create: true
        )
    }

    /// Documents directory for the current user (~/Documents).
    ///
    /// Complexity: O(n) where n is the number of significant directories.
    /// specified by `FileManager.SearchPathDirectory`
    public static var documentsDirectory: URL {
        try! self.init(
            for: .documentDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Desktop directory for the current user (~/Desktop).
    ///
    /// Complexity: O(n) where n is the number of significant directories.
    /// specified by `FileManager.SearchPathDirectory`
    public static var desktopDirectory: URL {
        try! self.init(
            for: .desktopDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Application support files for the current user (~/Library/Application Support).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`.
    public static var applicationSupportDirectory: URL {
        try! self.init(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Downloads directory for the current user (~/Downloads).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var downloadsDirectory: URL {
        try! self.init(
            for: .downloadsDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Movies directory for the current user (~/Movies).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var moviesDirectory: URL {
        try! self.init(
            for: .moviesDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Music directory for the current user (~/Music).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var musicDirectory: URL {
        try! self.init(
            for: .musicDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Pictures directory for the current user (~/Pictures).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var picturesDirectory: URL {
        try! self.init(
            for: .picturesDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// The user’s Public sharing directory (~/Public).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var sharedPublicDirectory: URL {
        try! self.init(
            for: .sharedPublicDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Trash directory for the current user (~/.Trash).
    ///
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var trashDirectory: URL {
        try! self.init(
            for: .trashDirectory,
            in: .userDomainMask,
            create: true
        )
    }

    /// Returns the home directory for the specified user.
    public static func homeDirectory(forUser user: String) -> URL? {
        FileManager.default.homeDirectory(forUser: user)
    }

    /// Initializes a new URL from a search path directory and domain, creating the directory if
    /// specified, necessary, and possible.
    public init(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL? = nil,
        create shouldCreate: Bool = false
    ) throws {
        self = try FileManager.default.url(
            for: directory,
            in: domain,
            appropriateFor: url,
            create: shouldCreate
        )
    }
}

#endif
