import Foundation
import FileManagerKit

public struct FileManagerPlayground {

    public enum Item: Buildable {
        case file(File)
        case directory(Directory)
        case link(Link)

        func build(
            in path: URL,
            using fileManager: FileManagerKit
        ) throws {
            switch self {
            case .file(let file):
                try file.build(in: path, using: fileManager)
            case .directory(let dir):
                try dir.build(in: path, using: fileManager)
            case .link(let link):
                try link.build(in: path, using: fileManager)
            }
        }
    }

    @resultBuilder
    public enum DirectoryBuilder {

        public static func buildExpression<T: BuildableItem>(
            _ expression: T
        )
            -> [Item]
        {
            [expression.buildItem()]
        }

        public static func buildExpression<T: BuildableItem>(
            _ expressions: [T]
        )
            -> [Item]
        {
            expressions.map {
                $0.buildItem()
            }
        }

        public static func buildBlock(
            _ components: [Item]...
        ) -> [Item] {
            components.flatMap { $0 }
        }

        public static func buildExpression(
            _ expression: File
        ) -> [Item] {
            [.file(expression)]
        }

        public static func buildExpression(
            _ expression: Directory
        ) -> [Item] {
            [.directory(expression)]
        }

        public static func buildExpression(
            _ expression: Link
        ) -> [Item] {
            [.link(expression)]
        }

        // Optionally allow string literals to be treated as files:
        public static func buildExpression(
            _ expression: String
        ) -> [Item] {
            [.file(File(name: expression, contents: nil))]
        }

        public static func buildExpression(
            _ expression: [Item]
        ) -> [Item] {
            expression
        }

        public static func buildOptional(
            _ component: [Item]?
        ) -> [Item] {
            component ?? []
        }

        public static func buildEither(
            first component: [Item]
        ) -> [Item] {
            component
        }

        public static func buildEither(
            second component: [Item]
        ) -> [Item] {
            component
        }

        public static func buildArray(
            _ components: [[Item]]
        ) -> [Item] {
            components.flatMap { $0 }
        }
    }

    private let fileManager: FileManager
    private let directory: Directory
    private let rootUrl: URL

    public let playgroundDirUrl: URL

    public init(
        rootUrl: URL? = nil,
        rootName: String? = nil,
        fileManager: FileManager = .default,
        @DirectoryBuilder _ contentsClosure: () -> [Item] = { [] }
    ) {
        self.fileManager = fileManager
        self.rootUrl = rootUrl ?? self.fileManager.temporaryDirectory
        self.directory = .init(
            name: rootName ?? "FileManagerPlayground_\(UUID().uuidString)",
            contentsClosure
        )
        self.playgroundDirUrl = self.rootUrl.appending(path: directory.name)
    }

    @discardableResult
    public func build(  // no params
        ) throws -> (FileManager, URL)
    {
        try directory.build(in: rootUrl, using: fileManager)
        return (fileManager, playgroundDirUrl)
    }

    @discardableResult
    public func remove(  // no params
        ) throws -> (FileManager, URL)
    {
        if fileManager.exists(at: playgroundDirUrl) {
            try fileManager.delete(at: playgroundDirUrl)
        }
        return (fileManager, playgroundDirUrl)
    }

    public func test(
        _ testBlock: (FileManager, URL) throws -> Void
    ) throws {
        try directory.build(in: rootUrl, using: fileManager)
        try testBlock(fileManager, playgroundDirUrl)
        try fileManager.delete(at: playgroundDirUrl)
    }
}
