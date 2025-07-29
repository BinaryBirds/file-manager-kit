//
//  Directory.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

public struct Directory: Buildable {

    let name: String
    let attributes: [FileAttributeKey: Any]?
    let contents: [FileManagerPlayground.Item]

    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        @FileManagerPlayground.DirectoryBuilder _ contentsClosure: () ->
            [FileManagerPlayground.Item] = { [] }
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contentsClosure()
    }

    func build(
        in url: URL,
        using fileManager: FileManagerKit
    ) throws {
        let dirUrl = url.appending(path: name)
        try fileManager.createDirectory(
            at: dirUrl,
            attributes: attributes
        )

        for item in contents {
            try item.build(in: dirUrl, using: fileManager)
        }
    }
}
