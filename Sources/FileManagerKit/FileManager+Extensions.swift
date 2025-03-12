import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension FileManager: FileManagerKit {

    // MARK: - exists

    public func exists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    public func directoryExists(at url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }

    public func fileExists(at url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path(), isDirectory: &isDirectory) {
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
        if lstat(url.path, &statInfo) == 0 {
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

    public func createDirectory(at url: URL) throws {
        guard !directoryExists(at: url) else {
            return
        }
        try createDirectory(
            atPath: url.path,
            withIntermediateDirectories: true,
            attributes: [
                .posixPermissions: 0o744
            ]
        )
    }

    public func createFile(at url: URL, contents data: Data?) throws {
        guard
            createFile(
                atPath: url.path(),
                contents: data,
                attributes: nil
            )
        else {
            throw CocoaError(.fileWriteUnknown)
        }
    }

    public func copy(from source: URL, to destination: URL) throws {
        try copyItem(at: source, to: destination)
    }

    public func move(from source: URL, to destination: URL) throws {
        try moveItem(at: source, to: destination)
    }

    public func link(from source: URL, to destination: URL) throws {
        try createSymbolicLink(at: destination, withDestinationURL: source)
    }

    public func delete(at url: URL) throws {
        try removeItem(at: url)
    }

    // MARK: - attributes

    public func setAttributes(
        _ attributes: [FileAttributeKey: Any],
        at url: URL
    ) throws {
        try setAttributes(attributes, ofItemAtPath: url.path)
    }

    public func attributes(at url: URL) throws -> [FileAttributeKey: Any] {
        try attributesOfItem(atPath: url.path)
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

    public func listDirectoryRecursively(at url: URL) -> [URL] {
        listDirectory(at: url)
            .reduce(into: [URL]()) { result, path in
                let itemUrl = url.appendingPathComponent(path)

                if directoryExists(at: itemUrl) {
                    result += listDirectoryRecursively(at: itemUrl)
                }
                else {
                    result.append(itemUrl)
                }
            }
    }

    public func copyRecursively(from inputURL: URL, to outputURL: URL) throws {
        guard directoryExists(at: inputURL) else {
            return
        }
        if !directoryExists(at: outputURL) {
            try createDirectory(at: outputURL)
        }

        for item in listDirectory(at: inputURL) {
            let itemSourceUrl = inputURL.appendingPathComponent(item)
            let itemDestinationUrl = outputURL.appendingPathComponent(item)
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
}
