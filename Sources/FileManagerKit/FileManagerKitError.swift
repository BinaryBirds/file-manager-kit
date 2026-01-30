//
//  FileManagerKitError.swift
//
//  Created by Binary Birds.
//

import Foundation

/// The single error type thrown by FileManagerKit APIs.
///
/// Swift 6 typed throws is used throughout the module, so keep this error
/// stable and expressive.
public enum FileManagerKitError: Error, Sendable {

    // MARK: - Directory & file operations

    case directoryCreateFailed(url: URL, underlying: Error)
    case fileCreateFailed(url: URL)

    case copyFailed(source: URL, destination: URL, underlying: Error)
    case moveFailed(source: URL, destination: URL, underlying: Error)
    case deleteFailed(url: URL, underlying: Error)

    // MARK: - Attributes

    case attributesReadFailed(url: URL, underlying: Error)
    case attributesWriteFailed(url: URL, underlying: Error)

    case missingAttribute(url: URL, key: FileAttributeKey)
    case invalidAttributeType(
        url: URL,
        key: FileAttributeKey,
        expected: String,
        actual: String
    )

    // MARK: - POSIX

    /// Use this when you call POSIX APIs and have an `errno` value.
    case posixError(path: String, errno: Int32)
}
