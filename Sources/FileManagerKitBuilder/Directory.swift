//
//  Directory.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation

public struct Directory: Buildable {
    let name: String
    let attributes: [FileAttributeKey: Any]?
    let contents: [FileManagerPlayground.Item]

    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        @FileManagerPlayground.DirectoryBuilder _ contentsClosure: () ->
            [FileManagerPlayground.Item]
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contentsClosure()
    }

    public init(
        name: String,
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
