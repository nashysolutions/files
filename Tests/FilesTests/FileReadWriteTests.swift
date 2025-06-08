//
//  FileReadWriteTests.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

@Suite
struct FileReadWriteTests {
    
    @Test("Should throw an error when attempting to read a non-existent file.")
    func readNonExistentFile() throws {
        
        /// 1. Given - A mock resource representing a file that we will pretend doesn't exist.
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(filename: "NonExistentResource", enclosingFolder: folder)
        
        /// 2. And - We simulate a missing file by throwing a read error,
        /// while also asserting that the attempted read targets the correct file location.
        let simulatedError = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileReadNoSuchFileError,
            userInfo: [NSFilePathErrorKey: file.location.path]
        )
        
        let context = MockContext(
            readHandler: URLExpectation.throwingData(
                file.location,
                message: "File read should target the correct file location.",
                error: simulatedError
            )
        )
        
        #expect(
            "Should throw NSFileReadNoSuchFileError when attempting to read a non-existent file.", performing: {
                _ = try file.read(using: context)
            },
            throws: {
                let error = $0 as NSError
                return error.domain == NSCocoaErrorDomain &&
                error.code == NSFileReadNoSuchFileError
            }
        )
    }
}
