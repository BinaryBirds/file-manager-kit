import Foundation

public protocol FileManagerKit {

    var currentDirectoryPath: String { get }

    var homeDirectoryForCurrentUser: URL { get }

    var temporaryDirectory: URL { get }

    func exists(at url: URL) -> Bool

    func directoryExists(at url: URL) -> Bool

    func fileExists(at url: URL) -> Bool

    func linkExists(at url: URL) -> Bool

    func createDirectory(at url: URL) throws

    func listDirectory(at url: URL) -> [String]

    func createFile(at url: URL, contents: Data?) throws

    func copy(from source: URL, to destination: URL) throws

    func move(from source: URL, to destination: URL) throws

    func link(from source: URL, to destination: URL) throws

    func delete(at url: URL) throws

    func attributes(at url: URL) throws -> [FileAttributeKey: Any]

    func setAttributes(
        _ attributes: [FileAttributeKey: Any],
        at url: URL
    ) throws

    func setPermissions(_ permission: Int, at url: URL) throws

    func permissions(at url: URL) throws -> Int

    func size(at url: URL) throws -> UInt64

    func creationDate(at url: URL) throws -> Date

    func modificationDate(at url: URL) throws -> Date

    func listDirectoryRecursively(at url: URL) -> [URL]

    func copyRecursively(from inputURL: URL, to outputURL: URL) throws
}
