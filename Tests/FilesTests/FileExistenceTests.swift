//
//  FileExistenceTests.swift
//  files
//
//  Created by Robert Nash on 10/01/2025.
//

import Foundation
import Testing
import Files

@Suite
struct FileExistenceTests {
    
    @Test("Verifies that a file exists.")
    func testFileExists() throws {
        
        /// 1. Given - A file located in a test folder
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(filename: "Resource", enclosingFolder: folder)
        
        /// 2. And - A context that confirms file existence
        let context = MockContext(
            fileExistsHandler: { location in
                #expect(location == file.location, "Should query the correct file location.")
                return true
            },
            folderExistsHandler: { location in
                #expect(location == file.location, "Should query the correct file location.")
                return true
            }
        )

        /// 3. When - Checking if the file exists
        let result = file.exists(using: context)
        
        /// 4. Then - The file should be reported as existing
        #expect(result, "File should exist.")
        
        /// 5. And - The correct endpoint should be called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.fileExists), "The correct endpoint should have been called.")
    }
    
    @Test("Verifies that a file does not exist.")
    func testFileDoesNotExist() throws {
        
        /// 1. Given - A file located in a test folder
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(filename: "Resource", enclosingFolder: folder)
        
        /// 2. And - A context that reports the file is missing
        let context = MockContext(
            fileExistsHandler: { location in
                #expect(location == file.location, "Should query the correct file location.")
                return false
            },
            folderExistsHandler: { location in
                #expect(location == file.location, "Should query the correct file location.")
                return true
            }
        )

        /// 3. When - Checking if the file exists
        let result = file.exists(using: context)
        
        /// 4. Then - The file should be reported as missing
        #expect(!result, "File should not exist.")
        
        /// 5. And - The correct endpoint should be called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.fileExists), "The correct endpoint should have been called.")
    }
}
