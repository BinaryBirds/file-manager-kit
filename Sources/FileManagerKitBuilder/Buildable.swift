//
//  Buildable.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 30..
//

import Foundation

protocol Buildable {
    
    func build(in path: URL, using fileManager: FileManager) throws
}
