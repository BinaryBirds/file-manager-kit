import Foundation

private protocol Buildable {

    func build(in path: URL, using fileManager: FileManager) throws
}

public struct File: ExpressibleByStringLiteral, Buildable {
    private let name: String
    private let attributes: [FileAttributeKey: Any]?
    private let contents: Data?

    public init(
        _ name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        contents: Data? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contents
    }

    public init(
        _ name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        string: String? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = string?.data(using: .utf8)
    }

    public init(stringLiteral value: String) {
        self.init(value, contents: nil)
    }

    func build(
        in url: URL,
        using fileManager: FileManager
    ) throws {
        fileManager.createFile(
            atPath: url.appendingPathComponent(name).path(),
            contents: contents,
            attributes: attributes
        )
    }
}

public struct SymbolicLink: Buildable {
    fileprivate let name: String
    private let destination: String

    public init(_ name: String, destination: String) {
        self.name = name
        self.destination = destination
    }

    fileprivate func build(
        in url: URL,
        using fileManager: FileManager
    ) throws {
        let linkUrl = url.appendingPathComponent(name)
        let destUrl = url.appendingPathComponent(destination)
        try fileManager.createSymbolicLink(
            atPath: linkUrl.path(),
            withDestinationPath: destUrl.path()
        )
    }
}

public struct Directory: Buildable {
    fileprivate let name: String
    private let attributes: [FileAttributeKey: Any]?
    private let contents: [FileManagerPlayground.Item]

    public init(
        _ name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        @FileManagerPlayground.DirectoryBuilder _ contentsClosure: () ->
            [FileManagerPlayground.Item]
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contentsClosure()
    }

    public init(
        _ name: String,
        attributes: [FileAttributeKey: Any]? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = []
    }

    func build(
        in url: URL,
        using fileManager: FileManager
    ) throws {
        let dirUrl = url.appendingPathComponent(name)
        try fileManager.createDirectory(
            atPath: dirUrl.path(),
            withIntermediateDirectories: true,
            attributes: attributes
        )
        for item in contents {
            try item.build(in: dirUrl, using: fileManager)
        }
    }
}

public struct FileManagerPlayground {

    public enum Item: Buildable {
        case file(File)
        case directory(Directory)
        case symbolicLink(SymbolicLink)

        func build(
            in path: URL,
            using fileManager: FileManager
        ) throws {
            switch self {
            case .file(let file):
                try file.build(in: path, using: fileManager)
            case .directory(let dir):
                try dir.build(in: path, using: fileManager)
            case .symbolicLink(let symlink):
                try symlink.build(in: path, using: fileManager)
            }
        }
    }

    @resultBuilder
    public enum DirectoryBuilder {
        public static func buildBlock(_ components: [Item]...) -> [Item] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expression: File) -> [Item] {
            [.file(expression)]
        }

        public static func buildExpression(_ expression: Directory) -> [Item] {
            [.directory(expression)]
        }

        public static func buildExpression(_ expression: SymbolicLink) -> [Item]
        {
            [.symbolicLink(expression)]
        }

        // Optionally allow string literals to be treated as files:
        public static func buildExpression(_ expression: String) -> [Item] {
            [.file(File(expression, contents: nil))]
        }

        public static func buildExpression(_ expression: [Item]) -> [Item] {
            expression
        }

        public static func buildOptional(_ component: [Item]?) -> [Item] {
            component ?? []
        }

        public static func buildEither(first component: [Item]) -> [Item] {
            component
        }

        public static func buildEither(second component: [Item]) -> [Item] {
            component
        }

        public static func buildArray(_ components: [[Item]]) -> [Item] {
            components.flatMap { $0 }
        }
    }

    private let fileManager: FileManager
    private let directory: Directory
    private let rootUrl: URL

    public init(
        rootUrl: URL? = nil,
        rootName: String? = nil,
        fileManager: FileManager = .default,
        @DirectoryBuilder _ contentsClosure: () -> [Item]
    ) {
        self.fileManager = fileManager
        self.rootUrl = rootUrl ?? self.fileManager.temporaryDirectory

        let name = rootName ?? "FileManagerPlayground_\(UUID().uuidString)"
        self.directory = .init(
            name,
            contentsClosure
        )
    }

    public init(
        fileManager: FileManager = .default,
        @DirectoryBuilder _ contentsClosure: () -> [Item]
    ) {
        self.fileManager = fileManager
        self.rootUrl = self.fileManager.temporaryDirectory

        self.directory = .init(
            "FileManagerPlayground_\(UUID().uuidString)",
            contentsClosure
        )
    }

    public init(
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.rootUrl = self.fileManager.temporaryDirectory

        self.directory = .init("FileManagerPlayground_\(UUID().uuidString)", {})
    }

    public func test(_ tester: (FileManager, URL) throws -> Void) throws {
        try directory.build(in: rootUrl, using: fileManager)
        let createdDir = rootUrl.appendingPathComponent(directory.name)
        try tester(fileManager, createdDir)
        try fileManager.removeItem(atPath: createdDir.path())
    }
}
