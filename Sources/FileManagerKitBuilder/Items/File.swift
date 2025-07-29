//
//  File.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

public struct File: ExpressibleByStringLiteral, Buildable {

    let name: String
    let attributes: [FileAttributeKey: Any]?
    let contents: Data?

    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        contents: Data? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.contents = contents
    }

    public init(
        name: String,
        attributes: [FileAttributeKey: Any]? = nil,
        string: String? = nil
    ) {
        self.init(
            name: name,
            attributes: attributes,
            contents: string?.data(using: .utf8)
        )
    }

    public init(
        stringLiteral value: String
    ) {
        self.init(name: value, string: nil)
    }

    func build(
        in url: URL,
        using fileManager: FileManagerKit
    ) throws {
        try fileManager.createFile(
            at: url.appending(path: name),
            contents: contents,
            attributes: attributes
        )
    }
}
