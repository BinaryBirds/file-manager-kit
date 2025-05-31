//
//  File.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 01..
//

import Foundation
import Testing

@testable import FileManagerKitBuilder

struct DirectoryBuilderTests {

    @Test
    func builder_AllFeatures() throws {
        let includeOptional = true
        let useFirst = false
        let useThird = true
        let dynamicFiles = (1...2)
            .map { i in
                File(name: "dynamic\(i).txt", contents: nil)
            }
        let injected: [FileManagerPlayground.Item] = [
            .file(File(name: "injected1.txt", contents: nil)),
            .file(File(name: "injected2.txt", contents: nil)),
        ]

        try FileManagerPlayground {
            Directory(name: "root") {
                File("static.md")

                if includeOptional {
                    "optional.txt"
                }

                if useFirst {
                    "first-choice.txt"
                }
                else {
                    "second-choice.txt"
                }

                if useThird {
                    "third-choice.txt"
                }
                else {
                    File("forth-choice.txt")
                }

                Directory(name: "looped") {
                    for file in dynamicFiles {
                        file
                    }
                }

                Directory(name: "empty") {}

                Directory(name: "nested") {
                    Directory(name: "deeper") {
                        "deep.txt"
                    }
                }

                SymbolicLink(name: "link", destination: "static.md")

                injected

                // Multiple arrays in one block
                [
                    .file(File("array1.txt")),
                    .file(File("array2.txt")),
                ]
                [
                    .file(File("array3.txt"))
                ]

                // Custom BuildableItem
                JSON(name: "encoded-name", contents: EncodeMe(name: "MyName"))
            }
            Directory(name: "not-root") {
                "string"
                JSON(name: "encoded-name", contents: EncodeMe(name: "MyName"))
                [
                    JSON(
                        name: "encoded-name-me",
                        contents: EncodeMe(name: "MyName")
                    ),
                    JSON(
                        name: "encoded-name-you",
                        contents: EncodeMe(name: "YourName")
                    ),
                ]
            }
        }
        .test { fileManager, rootUrl in
            let checkPaths = [
                "root/static.md",
                "root/optional.txt",
                "root/second-choice.txt",
                "root/third-choice.txt",
                "root/looped/dynamic1.txt",
                "root/looped/dynamic2.txt",
                "root/empty",
                "root/nested/deeper/deep.txt",
                "root/link",
                "root/injected1.txt",
                "root/injected2.txt",
                "root/array1.txt",
                "root/array2.txt",
                "root/array3.txt",
                "root/encoded-name.json",
                "not-root/string",
                "not-root/encoded-name.json",
                "not-root/encoded-name-me.json",
                "not-root/encoded-name-you.json",
            ]

            for path in checkPaths {
                let url = rootUrl.appending(path: path)
                #expect(
                    fileManager.exists(at: url),
                    "Expected file or directory at: \(path)"
                )
            }
        }
    }
}
