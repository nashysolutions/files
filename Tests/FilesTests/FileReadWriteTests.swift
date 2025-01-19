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

        /// 1. Given - A mock resource representing a file.
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(name: "NonExistentResource", enclosingFolder: folder)
        
        /// 2. And - We do not create the file.
        
        #expect(performing: {
            /// 3. When - We read the file
            _ = try file.read()
        }, throws: {
            /// 4. Then - An error is thrown
            let error = $0 as NSError
            return error.domain == NSCocoaErrorDomain && error.code == 256
        })
    }
}
