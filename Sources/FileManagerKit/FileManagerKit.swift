import Foundation

/// A protocol that abstracts common file system operations, such as checking for file existence,
/// creating directories or files, copying, moving, deleting, and querying file attributes.
///
/// This protocol is useful for dependency injection and unit testing by allowing you to mock
/// file system behavior in conforming types.
public protocol FileManagerKit {

    /// The path to the current working directory.
    var currentDirectoryPath: String { get }

    /// The home directory URL for the current user.
    var homeDirectoryForCurrentUser: URL { get }

    /// The URL of the temporary directory.
    var temporaryDirectory: URL { get }

    // MARK: - exists

    /// Checks whether a file, directory, or link exists at the specified URL.
    ///
    /// - Parameter url: The URL to check for existence.
    /// - Returns: `true` if the item exists, otherwise `false`.
    func exists(
        at url: URL
    ) -> Bool

    /// Determines whether a directory exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a directory exists at the URL, otherwise `false`.
    func directoryExists(
        at url: URL
    ) -> Bool

    /// Determines whether a file exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a file exists at the URL, otherwise `false`.
    func fileExists(
        at url: URL
    ) -> Bool

    /// Determines whether a link exists at the specified URL.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if a link exists at the URL, otherwise `false`.
    func linkExists(
        at url: URL
    ) -> Bool

    // MARK: -

    /// Creates a directory at the specified URL with optional attributes.
    ///
    /// - Parameters:
    ///   - url: The location where the directory should be created.
    ///   - attributes: Optional file attributes to assign to the new directory.
    /// - Throws: An error if the directory could not be created.
    func createDirectory(
        at url: URL,
        attributes: [FileAttributeKey: Any]?
    ) throws

    /// Creates a file at the specified URL with optional contents.
    ///
    /// - Parameters:
    ///   - url: The location where the file should be created.
    ///   - contents: Optional data to write into the file.
    /// - Throws: An error if the file could not be created.
    func createFile(
        at url: URL,
        contents: Data?,
        attributes: [FileAttributeKey: Any]?
    ) throws

    /// Copies a file or directory from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The original location of the file or directory.
    ///   - destination: The target location.
    /// - Throws: An error if the item could not be copied.
    func copy(
        from source: URL,
        to destination: URL
    ) throws

    /// Recursively copies a directory and its contents from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - inputURL: The root directory to copy.
    ///   - outputURL: The destination root directory.
    /// - Throws: An error if the operation fails.
    func copyRecursively(
        from inputURL: URL,
        to outputURL: URL
    ) throws

    /// Moves a file or directory from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The original location of the file or directory.
    ///   - destination: The new location.
    /// - Throws: An error if the item could not be moved.
    func move(
        from source: URL,
        to destination: URL
    ) throws

    /// Creates a symbolic (soft) link from a source path to a destination path.
    ///
    /// - Parameters:
    ///   - source: The target of the link.
    ///   - destination: The location where the symbolic link should be created.
    /// - Throws: An error if the soft link could not be created.
    func softLink(
        from source: URL,
        to destination: URL
    ) throws

    /// Creates a hard link from a source path to a destination path.
    ///
    /// - Parameters:
    ///   - source: The target of the link.
    ///   - destination: The location where the hard link should be created.
    /// - Throws: An error if the hard link could not be created.
    func hardLink(
        from source: URL,
        to destination: URL
    ) throws

    /// Deletes the file, directory, or symbolic link at the specified URL.
    ///
    /// - Parameter url: The URL of the item to delete.
    /// - Throws: An error if the item could not be deleted.
    func delete(
        at url: URL
    ) throws

    // MARK: -

    /// Lists the contents of the directory at the specified URL.
    ///
    /// - Parameter url: The directory URL.
    /// - Returns: An array of item names in the directory.
    func listDirectory(
        at url: URL
    ) -> [String]

    /// Recursively lists all files and directories under the specified URL.
    ///
    /// - Parameter url: The root directory to list.
    /// - Returns: An array of URLs representing all items found recursively.
    func listDirectoryRecursively(
        at url: URL
    ) -> [URL]

    // MARK: - attributes

    /// Retrieves the file attributes at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: A dictionary of file attributes.
    /// - Throws: An error if attributes could not be retrieved.
    func attributes(
        at url: URL
    ) throws -> [FileAttributeKey: Any]

    /// Retrieves the POSIX permissions for the file or directory at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The POSIX permission value.
    /// - Throws: An error if the permissions could not be retrieved.
    func permissions(
        at url: URL
    ) throws -> Int

    /// Returns the size of the file at the specified URL in bytes.
    ///
    /// - Parameter url: The file URL.
    /// - Returns: The size of the file in bytes.
    /// - Throws: An error if the size could not be retrieved.
    func size(
        at url: URL
    ) throws -> UInt64

    /// Retrieves the creation date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The creation date.
    /// - Throws: An error if the creation date could not be retrieved.
    func creationDate(
        at url: URL
    ) throws -> Date

    /// Retrieves the last modification date of the item at the specified URL.
    ///
    /// - Parameter url: The file or directory URL.
    /// - Returns: The modification date.
    /// - Throws: An error if the modification date could not be retrieved.
    func modificationDate(
        at url: URL
    ) throws -> Date

    /// Sets the file attributes at the specified URL.
    ///
    /// - Parameters:
    ///   - attributes: A dictionary of attributes to apply.
    ///   - url: The file or directory URL.
    /// - Throws: An error if the attributes could not be set.
    func setAttributes(
        _ attributes: [FileAttributeKey: Any],
        at url: URL
    ) throws

    /// Sets the POSIX file permissions at the specified URL.
    ///
    /// - Parameters:
    ///   - permission: The POSIX permission value.
    ///   - url: The file or directory URL.
    /// - Throws: An error if the permissions could not be set.
    func setPermissions(
        _ permission: Int,
        at url: URL
    ) throws
}
