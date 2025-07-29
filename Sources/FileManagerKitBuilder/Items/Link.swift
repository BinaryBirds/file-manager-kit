//
//  Link.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation
import FileManagerKit

public struct Link: Buildable {

    let name: String
    let target: String
    let isSymbolic: Bool

    public init(
        name: String,
        target: String,
        isSymbolic: Bool = true
    ) {
        self.name = name
        self.target = target
        self.isSymbolic = isSymbolic
    }

    func build(
        in url: URL,
        using fileManager: FileManagerKit
    ) throws {
        let linkUrl = url.appending(path: name)
        let targetUrl = url.appending(path: target)
        if isSymbolic {
            try fileManager.softLink(from: targetUrl, to: linkUrl)
        }
        else {
            try fileManager.hardLink(from: targetUrl, to: linkUrl)
        }
    }
}
