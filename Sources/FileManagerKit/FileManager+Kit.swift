//
//  FileManager+Kit.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

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

private extension String {
    #if canImport(FoundationEssentials)
    var fmkit_removingPercentEncoding: String { self }
    #else
    var fmkit_removingPercentEncoding: String {
        self.removingPercentEncoding ?? self
    }
    #endif
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
        #if canImport(FoundationEssentials)
        var isDirectory = false
        if fileExists(
            atPath: url.path(percentEncoded: false),
            isDirectory: &isDirectory
        ) {
            return isDirectory
        }
        #else
        var isDirectory = ObjCBool(false)
        if fileExists(
            atPath: url.path(percentEncoded: false),
            isDirectory: &isDirectory
        ) {
            return isDirectory.boolValue
        }
        #endif
        return false
    }

    /// Determines whether a file exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a file exists at the URL, otherwise `false`.
    public func fileExists(
        at url: URL
    ) -> Bool {
        #if canImport(FoundationEssentials)
        var isDirectory = false
        if fileExists(
            atPath: url.path(
                percentEncoded: false
            ),
            isDirectory: &isDirectory
        ) {
            return !isDirectory
        }
        #else
        var isDirectory = ObjCBool(false)
        if fileExists(
            atPath: url.path(
                percentEncoded: false
            ),
            isDirectory: &isDirectory
        ) {
            return !isDirectory.boolValue
        }
        #endif
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
        attributes: [FileAttributeKey: Any]?
    ) throws(FileManagerKitError) {
        guard !directoryExists(at: url) else {
            return
        }
        do {
            try createDirectory(
                atPath: url.path(percentEncoded: false),
                withIntermediateDirectories: true,
                attributes: attributes
            )
        }
        catch {
            throw .directoryCreateFailed(url: url, underlying: error)
        }
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
        attributes: [FileAttributeKey: Any]?
    ) throws(FileManagerKitError) {
        guard
            createFile(
                atPath: url.path(percentEncoded: false),
                contents: contents,
                attributes: attributes
            )
        else {
            throw .fileCreateFailed(url: url)
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
    ) throws(FileManagerKitError) {
        do {
            try copyItem(at: source, to: destination)
        }
        catch {
            throw .copyFailed(
                source: source,
                destination: destination,
                underlying: error
            )
        }
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
    ) throws(FileManagerKitError) {
        guard directoryExists(at: inputURL) else {
            return
        }
        if !directoryExists(at: outputURL) {
            try createDirectory(at: outputURL, attributes: nil)
        }

        for item in listDirectory(at: inputURL) {
            let path = item.fmkit_removingPercentEncoding
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
    ) throws(FileManagerKitError) {
        do {
            try moveItem(at: source, to: destination)
        }
        catch {
            throw .moveFailed(
                source: source,
                destination: destination,
                underlying: error
            )
        }
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
    ) throws(FileManagerKitError) {
        do {
            try createSymbolicLink(
                at: destination,
                withDestinationURL: source
            )
        }
        catch {
            throw .copyFailed(
                source: source,
                destination: destination,
                underlying: error
            )
        }
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
    ) throws(FileManagerKitError) {
        do {
            try linkItem(at: source, to: destination)
        }
        catch {
            throw .copyFailed(
                source: source,
                destination: destination,
                underlying: error
            )
        }
    }

    /// Deletes the file, directory, or symbolic link at the specified URL.
    ///
    /// - Parameter url: The URL of the item to delete.
    /// - Throws: An error if the item could not be deleted.
    public func delete(at url: URL) throws(FileManagerKitError) {
        do {
            try removeItem(at: url)
        }
        catch {
            throw .deleteFailed(url: url, underlying: error)
        }
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
    ) throws(FileManagerKitError) -> [FileAttributeKey: Any] {
        do {
            return try attributesOfItem(
                atPath: url.path(
                    percentEncoded: false
                )
            )
        }
        catch {
            throw .attributesReadFailed(url: url, underlying: error)
        }
    }

    /// Retrieves the POSIX permissions for the file or directory at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The POSIX permission value.
    /// - Throws: An error if the permissions could not be retrieved.
    public func permissions(
        at url: URL
    ) throws(FileManagerKitError) -> Int {
        let attrs = try attributes(at: url)

        guard let raw = attrs[.posixPermissions] else {
            throw .missingAttribute(url: url, key: .posixPermissions)
        }
        if let int = raw as? Int {
            return int
        }

        throw .invalidAttributeType(
            url: url,
            key: .posixPermissions,
            expected: "Int",
            actual: String(describing: type(of: raw))
        )
    }

    /// Returns the size of the file at the specified URL in bytes.
    ///
    /// - Parameter url: The file URL.
    /// - Returns: The size of the file in bytes.
    /// - Throws: An error if the size could not be retrieved.
    public func size(
        at url: URL
    ) throws(FileManagerKitError) -> UInt64 {
        if fileExists(at: url) {
            let attributes = try attributes(at: url)
            if let intSize = attributes[.size] as? Int {
                return UInt64(intSize)
            }
            if let int64Size = attributes[.size] as? Int64 {
                return UInt64(int64Size)
            }
            #if !canImport(FoundationEssentials)
            if let num = attributes[.size] as? NSNumber {
                return num.uint64Value
            }
            #endif
            return 0
        }

        var total: UInt64 = 0
        let all = listDirectoryRecursively(at: url)
        for fileURL in all {
            if fileExists(at: fileURL) {
                #if !canImport(FoundationEssentials)
                let keys: [URLResourceKey] = [
                    .totalFileAllocatedSizeKey, .fileAllocatedSizeKey,
                ]
                if let values = try? fileURL.resourceValues(forKeys: Set(keys))
                {
                    if let s = values.totalFileAllocatedSize
                        ?? values.fileAllocatedSize
                    {
                        total += UInt64(s)
                        continue
                    }
                }
                #endif
                if let attrs = try? attributes(at: fileURL) {
                    if let intSize = attrs[.size] as? Int {
                        total += UInt64(intSize)
                    }
                    else if let int64Size = attrs[.size] as? Int64 {
                        total += UInt64(int64Size)
                    }
                    else {
                        #if !canImport(FoundationEssentials)
                        if let num = attrs[.size] as? NSNumber {
                            total += num.uint64Value
                        }
                        #endif
                    }
                }
            }
        }
        return total
    }

    /// Retrieves the creation date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The creation date.
    /// - Throws: An error if the creation date could not be retrieved.
    public func creationDate(
        at url: URL
    ) throws(FileManagerKitError) -> Date {
        let attr = try attributes(at: url)

        if let d = attr[.creationDate] as? Date {
            return d
        }
        // On Linux, we return the modification date, since no .creationDate
        if let d = attr[.modificationDate] as? Date {
            return d
        }

        throw .missingAttribute(url: url, key: .creationDate)
    }

    /// Retrieves the last modification date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The modification date.
    /// - Throws: An error if the modification date could not be retrieved.
    public func modificationDate(
        at url: URL
    ) throws(FileManagerKitError) -> Date {
        let attr = try attributes(at: url)

        guard let raw = attr[.modificationDate] else {
            throw .missingAttribute(url: url, key: .modificationDate)
        }
        if let d = raw as? Date {
            return d
        }

        throw .invalidAttributeType(
            url: url,
            key: .modificationDate,
            expected: "Date",
            actual: String(describing: type(of: raw))
        )
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
    ) throws(FileManagerKitError) {
        do {
            try setAttributes(
                attributes,
                ofItemAtPath: url.path(
                    percentEncoded: false
                )
            )
        }
        catch {
            throw .attributesWriteFailed(url: url, underlying: error)
        }
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
    ) throws(FileManagerKitError) {
        try setAttributes([.posixPermissions: permission], at: url)
    }

}
