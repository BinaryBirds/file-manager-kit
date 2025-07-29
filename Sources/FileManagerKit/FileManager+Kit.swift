//
//  FileManager+Kit.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

private extension URL {

    /// Computes a relative path from the current URL (`self`) to another base URL.
    ///
    /// This method compares the standardized path components of both URLs,
    /// identifies their shared prefix, and removes it from the current URL path
    /// to return a relative path string.
    ///
    /// - Parameter url: The base URL to which the path should be made relative.
    /// - Returns: A relative path string from `url` to `self`.
    func relativePath(to url: URL) -> String {
        // Break both paths into components (standardized removes '.', '..', etc.)
        let components = standardized.pathComponents
        let baseComponents = url.standardized.pathComponents

        // Determine how many leading components are shared between both paths
        let commonPrefixCount = zip(components, baseComponents)
            .prefix { $0 == $1 }
            .count

        // Remove the common prefix to compute the relative path
        let relativeComponents = components.dropFirst(commonPrefixCount)

        // Join the remaining components with "/" to form the relative path
        return relativeComponents.joined(separator: "/")
    }
}

extension FileManager: FileManagerKit {

    // MARK: -

    /// Checks whether a file, directory, or link exists at the specified URL.
    ///
    /// - Parameter url: The URL to check for existence.
    /// - Returns: `true` if the item exists, otherwise `false`.
    public func exists(
        at url: URL
    ) -> Bool {
        fileExists(
            atPath: url.path(
                percentEncoded: false
            )
        )
    }

    /// Determines whether a directory exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a directory exists at the URL, otherwise `false`.
    public func directoryExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(
            atPath: url.path(percentEncoded: false),
            isDirectory: &isDirectory
        ) {
            return isDirectory.boolValue
        }
        return false
    }

    /// Determines whether a file exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a file exists at the URL, otherwise `false`.
    public func fileExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(
            atPath: url.path(
                percentEncoded: false
            ),
            isDirectory: &isDirectory
        ) {
            return !isDirectory.boolValue
        }
        return false
    }

    /// Determines whether a link exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a link exists at the URL, otherwise `false`.
    public func linkExists(
        at url: URL
    ) -> Bool {
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        let resourceValues = try? url.resourceValues(forKeys: [
            .isSymbolicLinkKey
        ])
        if let isSymbolicLink = resourceValues?.isSymbolicLink {
            return isSymbolicLink
        }
        #else
        var statInfo = stat()
        if lstat(url.path(percentEncoded: false), &statInfo) == 0 {
            return (statInfo.st_mode & S_IFMT) == S_IFLNK
        }
        #endif
        return false
    }

    // MARK: -

    /// Creates a directory at the specified URL with optional attributes.
    ///
    /// - Parameters:
    ///   - url: The location where the directory should be created.
    ///   - attributes: Optional file attributes to assign to the new directory.
    /// - Throws: An error if the directory could not be created.
    public func createDirectory(
        at url: URL,
        attributes: [FileAttributeKey: Any]? = [
            .posixPermissions: 0o744
        ]
    ) throws {
        guard !directoryExists(at: url) else {
            return
        }
        try createDirectory(
            atPath: url.path(percentEncoded: false),
            withIntermediateDirectories: true,
            attributes: attributes
        )
    }

    /// Creates a file at the specified URL with optional contents and attributes.
    ///
    /// - Parameters:
    ///   - url: The location where the file should be created.
    ///   - contents: Optional data to write into the file.
    ///   - attributes: Optional file attributes to apply to the file, such as permissions.
    /// - Throws: An error if the file could not be created.
    public func createFile(
        at url: URL,
        contents: Data?,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        guard
            createFile(
                atPath: url.path(percentEncoded: false),
                contents: contents,
                attributes: attributes
            )
        else {
            throw CocoaError(.fileWriteUnknown)
        }
    }

    /// Copies a file or directory from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The original location of the file or directory.
    ///   - destination: The target location.
    /// - Throws: An error if the item could not be copied.
    public func copy(
        from source: URL,
        to destination: URL
    ) throws {
        try copyItem(at: source, to: destination)
    }

    /// Recursively copies a directory and its contents from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - inputURL: The root directory to copy.
    ///   - outputURL: The destination root directory.
    /// - Throws: An error if the operation fails.
    public func copyRecursively(
        from inputURL: URL,
        to outputURL: URL
    ) throws {
        guard directoryExists(at: inputURL) else {
            return
        }
        if !directoryExists(at: outputURL) {
            try createDirectory(at: outputURL)
        }

        for item in listDirectory(at: inputURL) {
            let path = item.removingPercentEncoding ?? item
            let itemSourceUrl = inputURL.appending(path: path)
            let itemDestinationUrl = outputURL.appending(path: path)
            if fileExists(at: itemSourceUrl) {
                if fileExists(at: itemDestinationUrl) {
                    try delete(at: itemDestinationUrl)
                }
                try copy(from: itemSourceUrl, to: itemDestinationUrl)
            }
            else {
                try copyRecursively(from: itemSourceUrl, to: itemDestinationUrl)
            }
        }
    }

    /// Moves a file or directory from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The original location of the file or directory.
    ///   - destination: The new location.
    /// - Throws: An error if the item could not be moved.
    public func move(
        from source: URL,
        to destination: URL
    ) throws {
        try moveItem(at: source, to: destination)
    }

    /// Creates a symbolic (soft) link from a source path to a destination path.
    ///
    /// - Parameters:
    ///   - source: The target of the link.
    ///   - destination: The location where the symbolic link should be created.
    /// - Throws: An error if the soft link could not be created.
    public func softLink(
        from source: URL,
        to destination: URL
    ) throws {
        try createSymbolicLink(
            at: destination,
            withDestinationURL: source
        )
    }

    /// Creates a hard link from a source path to a destination path.
    ///
    /// - Parameters:
    ///   - source: The target of the link.
    ///   - destination: The location where the hard link should be created.
    /// - Throws: An error if the hard link could not be created.
    public func hardLink(
        from source: URL,
        to destination: URL
    ) throws {
        try linkItem(at: source, to: destination)
    }

    /// Deletes the file, directory, or symbolic link at the specified URL.
    ///
    /// - Parameter url: The URL of the item to delete.
    /// - Throws: An error if the item could not be deleted.
    public func delete(at url: URL) throws {
        try removeItem(at: url)
    }

    // MARK: -

    /// Lists the contents of the directory at the specified URL.
    ///
    /// - Parameter url: The directory URL.
    /// - Returns: An array of item names in the directory.
    public func listDirectory(
        at url: URL
    ) -> [String] {
        guard directoryExists(at: url) else {
            return []
        }
        let list = try? contentsOfDirectory(atPath: url.path)
        return list?.map { $0 } ?? []
    }

    /// Recursively lists all files and directories under the specified URL.
    ///
    /// - Parameter url: The root directory to list.
    /// - Returns: An array of URLs representing all items found recursively.
    public func listDirectoryRecursively(
        at url: URL
    ) -> [URL] {
        let list = listDirectory(at: url)

        return list.reduce(into: [URL]()) { result, path in
            let itemUrl = url.appending(path: path)

            if directoryExists(at: itemUrl) {
                result += listDirectoryRecursively(at: itemUrl)
            }
            else {
                result.append(itemUrl)
            }
        }
    }

    /// Finds file or directory names within a specified directory that match optional name or extension filters.
    ///
    /// This method can search recursively and optionally skip hidden files.
    ///
    /// - Parameters:
    ///   - name: An optional base name to match (excluding the file extension). If `nil`, all names are matched.
    ///   - extensions: An optional list of file extensions to match (e.g., `["txt", "md"]`). If `nil`, all extensions are matched.
    ///   - recursively: Whether to include subdirectories in the search.
    ///   - skipHiddenFiles: Whether to exclude hidden files and directories (those starting with a dot).
    ///   - url: The root directory URL to search in.
    /// - Returns: A list of matching file or directory names as relative paths from the input URL.
    public func find(
        name: String? = nil,
        extensions: [String]? = nil,
        recursively: Bool = false,
        skipHiddenFiles: Bool = true,
        at url: URL
    ) -> [String] {
        var items: [String] = []
        if recursively {
            items = listDirectoryRecursively(at: url)
                .map {
                    // Convert to a relative path based on the root URL
                    $0.relativePath(to: url)
                }
        }
        else {
            items = listDirectory(at: url)
        }

        if skipHiddenFiles {
            items = items.filter { !$0.hasPrefix(".") }
        }

        return items.filter { fileName in
            let fileURL = URL(fileURLWithPath: fileName)
            let baseName = fileURL.deletingPathExtension().lastPathComponent
            let ext = fileURL.pathExtension

            switch (name, extensions) {
            case (nil, nil):
                return true
            case (let name?, nil):
                return baseName == name
            case (nil, let extensions?):
                return extensions.contains(ext)
            case let (name?, extensions?):
                return baseName == name && extensions.contains(ext)
            }
        }
    }

    // MARK: -

    /// Retrieves the file attributes at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: A dictionary of file attributes.
    /// - Throws: An error if attributes could not be retrieved.
    public func attributes(
        at url: URL
    ) throws -> [FileAttributeKey: Any] {
        try attributesOfItem(
            atPath: url.path(
                percentEncoded: false
            )
        )
    }

    /// Retrieves the POSIX permissions for the file or directory at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The POSIX permission value.
    /// - Throws: An error if the permissions could not be retrieved.
    public func permissions(
        at url: URL
    ) throws -> Int {
        let attributes = try attributes(at: url)
        return attributes[.posixPermissions] as! Int
    }

    /// Returns the size of the file at the specified URL in bytes.
    ///
    /// - Parameter url: The file URL.
    /// - Returns: The size of the file in bytes.
    /// - Throws: An error if the size could not be retrieved.
    public func size(
        at url: URL
    ) throws -> UInt64 {
        if fileExists(at: url) {
            let attributes = try attributes(at: url)
            let size = attributes[.size] as! NSNumber
            return size.uint64Value
        }
        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        guard
            let enumerator = enumerator(
                at: url,
                includingPropertiesForKeys: Array(keys)
            )
        else {
            return 0
        }

        var size: UInt64 = 0
        for item in enumerator.compactMap({ $0 as? URL }) {
            let values = try item.resourceValues(forKeys: keys)
            guard values.isRegularFile ?? false else {
                continue
            }
            size += UInt64(
                values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0
            )
        }
        return size
    }

    /// Retrieves the creation date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The creation date.
    /// - Throws: An error if the creation date could not be retrieved.
    public func creationDate(
        at url: URL
    ) throws -> Date {
        let attr = try attributes(at: url)
        // On Linux, we return the modification date, since no .creationDate
        return attr[.creationDate] as? Date ?? attr[.modificationDate] as! Date
    }

    /// Retrieves the last modification date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The modification date.
    /// - Throws: An error if the modification date could not be retrieved.
    public func modificationDate(
        at url: URL
    ) throws -> Date {
        let attr = try attributes(at: url)
        return attr[.modificationDate] as! Date
    }

    // MARK: -

    /// Sets the file attributes at the specified URL.
    ///
    /// - Parameters:
    ///   - attributes: A dictionary of attributes to apply.
    ///   - url: The file or directory URL.
    /// - Throws: An error if the attributes could not be set.
    public func setAttributes(
        _ attributes: [FileAttributeKey: Any],
        at url: URL
    ) throws {
        try setAttributes(
            attributes,
            ofItemAtPath: url.path(
                percentEncoded: false
            )
        )
    }

    /// Sets the POSIX file permissions at the specified URL.
    ///
    /// - Parameters:
    ///   - permission: The POSIX permission value.
    ///   - url: The file or directory URL.
    /// - Throws: An error if the permissions could not be set.
    public func setPermissions(
        _ permission: Int,
        at url: URL
    ) throws {
        try setAttributes([.posixPermissions: permission], at: url)
    }

}
