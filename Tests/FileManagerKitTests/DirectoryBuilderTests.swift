//
//  File.swift
//  file-manager-kit
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 01..
//

import Foundation
import Testing

@testable import FileManagerKitTesting

struct DirectoryBuilderTests {

    @Test
    func builder_AllFeatures() throws {
        let includeOptional = true
        let useFirst = false
        let useThird = true
        let dynamicFiles = (1...2)
            .map { i in
                File("dynamic\(i).txt", contents: nil)
            }
        let injected: [FileManagerPlayground.Item] = [
            .file(File("injected1.txt", contents: nil)),
            .file(File("injected2.txt", contents: nil)),
        ]

        try FileManagerPlayground {
            Directory("root") {
                File("static.md")

                if includeOptional {
                    File("optional.txt")
                }

                if useFirst {
                    File("first-choice.txt")
                }
                else {
                    File("second-choice.txt")
                }

                if useThird {
                    File("third-choice.txt")
                }
                else {
                    File("forth-choice.txt")
                }

                Directory("looped") {
                    for file in dynamicFiles {
                        file
                    }
                }

                Directory("empty") {}

                Directory("nested") {
                    Directory("deeper") {
                        File("deep.txt")
                    }
                }

                SymbolicLink("link", destination: "static.md")

                injected

                // Multiple arrays in one block
                [
                    .file(File("array1.txt")),
                    .file(File("array2.txt")),
                ]
                [
                    .file(File("array3.txt"))
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
