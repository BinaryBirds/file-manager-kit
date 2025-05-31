//
//  JSON.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import FileManagerKit
import FileManagerKitBuilder
import Foundation

public struct JSON<T: Encodable>: BuildableItem {

    public let name: String
    public let ext: String
    public let contents: T

    public init(name: String, ext: String = "json", contents: T) {
        self.name = name
        self.ext = ext
        self.contents = contents
    }

    public func buildItem() -> FileManagerPlayground.Item {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try! encoder.encode(contents)
        let string = String(data: data, encoding: .utf8)!
        
        return .file(File(name: "\(name).\(ext)", string: string))
    }
}
