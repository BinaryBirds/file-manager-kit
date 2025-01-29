//
//  File 2.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 01. 28..
//

import Foundation
@testable import FileManagerKit

class MockFileManager {
    
    private var fileSystem: [URL: Item] = [:]
}

extension MockFileManager {
    
    enum Error: Swift.Error {
        case fileNotFound
        case directoryNotFound
        case itemAlreadyExists
//        case invalidOperation(String)
        case permissionDenied
        case unknown
    }
    
    enum Item {
        case file(File)
        case folder(Folder)
        case symlink(Symlink)
    }
    
    struct File {
        var data: Data
        var attributes: [FileAttributeKey: Any]
    }
    
    struct Folder {
        var creationDate: Date
        var attributes: [FileAttributeKey: Any]
    }
    
    struct Symlink {
        var source: URL
        var attributes: [FileAttributeKey: Any]
    }
}

extension MockFileManager: FileManagerKit {
    
    func exists(at url: URL) -> Bool {
        return fileSystem.keys.contains(url)
    }
    
    func directoryExists(at url: URL) -> Bool {
        guard let item = fileSystem[url] else { return false }
        if case .folder = item { return true }
        return false
    }
    
    func fileExists(at url: URL) -> Bool {
        guard let item = fileSystem[url] else { return false }
        if case .file = item { return true }
        return false
    }
    
    func linkExists(at url: URL) -> Bool {
        guard let item = fileSystem[url] else { return false }
        if case .symlink = item { return true }
        return false
    }
    
    func createDirectory(at url: URL) throws {
        guard !exists(at: url) else {
            throw Error.itemAlreadyExists
        }
        fileSystem[url] = .folder(.init(creationDate: Date(), attributes: [:]))
    }
    
    func listDirectory(at url: URL) -> [String] {
        let normalizedURL = url.path.hasSuffix("/") ? url : url.appendingPathComponent("")
        
        return fileSystem.keys
            .filter {
                let normalizedFileURL = $0.deletingLastPathComponent().resolvingSymlinksInPath()
                return normalizedFileURL == normalizedURL
                
            }
            .map { $0.lastPathComponent }
    }
    
    func createFile(at url: URL, contents: Data) throws {
        guard !exists(at: url) else {
            throw Error.itemAlreadyExists
        }
        fileSystem[url] = .file(.init(data: contents, attributes: [:]))
    }
    
    func copy(from source: URL, to destination: URL) throws {
        guard let item = fileSystem[source] else {
            throw Error.fileNotFound
        }
        guard !exists(at: destination) else {
            throw Error.itemAlreadyExists
        }
        fileSystem[destination] = item
    }
    
    func move(from source: URL, to destination: URL) throws {
        try copy(from: source, to: destination)
        try delete(at: source)
    }
    
    func link(from source: URL, to destination: URL) throws {
        guard exists(at: source) else {
            throw Error.fileNotFound
        }
        fileSystem[destination] = .symlink(.init(source: source, attributes: [:]))
    }
    
    func delete(at url: URL) throws {
        guard exists(at: url) else {
            throw Error.fileNotFound
        }
        fileSystem.removeValue(forKey: url)
    }
    
    func attributes(at url: URL) throws -> [FileAttributeKey: Any] {
        guard let item = fileSystem[url] else {
            throw NSError(domain: "MockFileManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Item does not exist"])
        }
        switch item {
        case .file(let file):
            return file.attributes
        case .folder(let folder):
            return folder.attributes
        case .symlink:
            return [:]
        }
    }
    
    func setAttributes(_ attributes: [FileAttributeKey: Any], at url: URL) throws {
        guard let item = fileSystem[url] else {
            throw NSError(domain: "MockFileManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Item does not exist"])
        }
        switch item {
        case .file(var file):
            file.attributes = attributes
            fileSystem[url] = .file(file)
        case .folder(var folder):
            folder.attributes = attributes
            fileSystem[url] = .folder(folder)
        case .symlink:
            throw NSError(domain: "MockFileManager", code: 516, userInfo: [NSLocalizedDescriptionKey: "Cannot set attributes on a symlink"])
        }
    }
    
    func setPermissions(_ permission: Int, at url: URL) throws {
        try setAttributes([.posixPermissions: NSNumber(value: permission)], at: url)
    }
    
    func permissions(at url: URL) throws -> Int {
        let attributes = try attributes(at: url)
        return (attributes[.posixPermissions] as? NSNumber)?.intValue ?? 0
    }
    
    func size(at url: URL) throws -> UInt64 {
        guard let item = fileSystem[url] else {
            throw NSError(domain: "MockFileManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Item does not exist"])
        }
        switch item {
        case .file(let file):
            return UInt64(file.data.count)
        case .folder:
            return 0
        case .symlink:
            return 0
        }
    }
    
    func creationDate(at url: URL) throws -> Date {
        guard let item = fileSystem[url] else {
            throw NSError(domain: "MockFileManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Item does not exist"])
        }
        switch item {
        case .folder(let folder):
            return folder.creationDate
        case .file, .symlink:
            throw NSError(domain: "MockFileManager", code: 516, userInfo: [NSLocalizedDescriptionKey: "Creation date not available for this type"])
        }
    }
    
    func modificationDate(at url: URL) throws -> Date {
        let attributes = try attributes(at: url)
        return attributes[.modificationDate] as? Date ?? Date()
    }
}
