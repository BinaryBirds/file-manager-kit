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

    // MARK: - exists

    public func exists(
        at url: URL
    ) -> Bool {
        fileExists(
            atPath: url.path(
                percentEncoded: false
            )
        )
    }

    public func directoryExists(at url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(
            atPath: url.path(percentEncoded: false),
            isDirectory: &isDirectory
        ) {
            return isDirectory.boolValue
        }
        return false
    }

    public func fileExists(at url: URL) -> Bool {
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

    public func linkExists(at url: URL) -> Bool {
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

    // MARK: - contents

    public func listDirectory(at url: URL) -> [String] {
        guard directoryExists(at: url) else {
            return []
        }
        let list = try? contentsOfDirectory(atPath: url.path)
        return list?.map { $0 } ?? []
    }

    // MARK: - operations

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

    public func createFile(
        at url: URL,
        contents data: Data?,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        guard
            createFile(
                atPath: url.path(percentEncoded: false),
                contents: data,
                attributes: attributes
            )
        else {
            throw CocoaError(.fileWriteUnknown)
        }
    }

    public func copy(
        from source: URL,
        to destination: URL
    ) throws {
        try copyItem(at: source, to: destination)
    }

    public func move(
        from source: URL,
        to destination: URL
    ) throws {
        try moveItem(at: source, to: destination)
    }

    public func softLink(
        from source: URL,
        to destination: URL
    ) throws {
        try createSymbolicLink(
            at: destination,
            withDestinationURL: source
        )
    }

    public func hardLink(
        from source: URL,
        to destination: URL
    ) throws {
        try linkItem(at: source, to: destination)
    }

    public func delete(at url: URL) throws {
        try removeItem(at: url)
    }

    // MARK: - attributes

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

    public func attributes(at url: URL) throws -> [FileAttributeKey: Any] {
        try attributesOfItem(
            atPath: url.path(
                percentEncoded: false
            )
        )
    }

    // MARK: - permission

    public func setPermissions(_ permission: Int, at url: URL) throws {
        try setAttributes([.posixPermissions: permission], at: url)
    }

    public func permissions(at url: URL) throws -> Int {
        let attributes = try attributes(at: url)
        return attributes[.posixPermissions] as! Int
    }

    // MARK: - size

    public func size(at url: URL) throws -> UInt64 {
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

    public func creationDate(at url: URL) throws -> Date {
        let attr = try attributes(at: url)
        // On Linux, we return the modification date, since no .creationDate
        return attr[.creationDate] as? Date ?? attr[.modificationDate] as! Date
    }

    public func modificationDate(at url: URL) throws -> Date {
        let attr = try attributes(at: url)
        return attr[.modificationDate] as! Date
    }

    // MARK: -

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

    //
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

    /// Find files in the specified directory that match the given name and extensions criteria.
    ///
    /// - Parameters: url: The URL of the directory to search.
    /// - Returns: An array of file names that match the specified criteria.
    func find(
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
}
