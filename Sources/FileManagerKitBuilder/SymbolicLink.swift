//
//  SymbolicLink.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation

public struct SymbolicLink: Buildable {
    fileprivate let name: String
    private let destination: String

    public init(name: String, destination: String) {
        self.name = name
        self.destination = destination
    }

    func build(
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
