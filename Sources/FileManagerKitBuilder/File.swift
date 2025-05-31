//
//  File.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation

public struct File: ExpressibleByStringLiteral, Buildable {
    private let name: String
    private let attributes: [FileAttributeKey: Any]?
    private let contents: Data?

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
        self.name = name
        self.attributes = attributes
        self.contents = string?.data(using: .utf8)
    }

    public init(stringLiteral value: String) {
        self.init(name: value, contents: nil)
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
