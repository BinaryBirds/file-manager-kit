import Foundation

extension FileManager {

    // MARK: - exists

    public static var currentDirectory: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    public func exists(
        at url: URL
    ) -> Bool {
        fileExists(atPath: url.path)
    }

    public func directoryExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }

    public func fileExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return !isDirectory.boolValue
        }
        return false
    }

    // TODO: linux support
    public func linkExists(
        at url: URL
    ) -> Bool {
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            let resourceValues = try! url.resourceValues(
                forKeys: [.isSymbolicLinkKey]
            )
            if let isSymbolicLink = resourceValues.isSymbolicLink {
                return isSymbolicLink
            }
        #endif
        return false
    }

    // MARK: - contents

    public func listDirectory(
        at url: URL,
        includingHiddenItems: Bool = false
    ) -> [String] {
        guard directoryExists(at: url) else {
            return []
        }
        var options: FileManager.DirectoryEnumerationOptions = []
        if !includingHiddenItems {
            options = [.skipsHiddenFiles]
        }
        let list = try? contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: options
        )
        return list?.map { $0.lastPathComponent } ?? []
    }

    // MARK: - operations

    public func createDirectory(
        at url: URL
    ) throws {
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

    public func link(
        from source: URL,
        to destination: URL
    ) throws {
        try createSymbolicLink(at: destination, withDestinationURL: source)
    }

    public func delete(
        at url: URL
    ) throws {
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

    public func setPermissions(
        _ permission: Int,
        at url: URL
    ) throws {
        try setAttributes([.posixPermissions: permission], at: url)
    }

    public func permissions(
        at url: URL
    ) throws -> Int {
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
        return attr[.creationDate] as! Date
    }

    public func modificationDate(at url: URL) throws -> Date {
        let attr = try attributes(at: url)
        return attr[.modificationDate] as! Date
    }
}
