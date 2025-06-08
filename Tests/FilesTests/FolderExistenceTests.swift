//
//  FolderExistenceTests.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation
import Testing
import Files

@Suite
struct FolderExistenceTests {
    
    @Test("Verifies that a folder exists.")
    func testFolderExists() throws {
        
        /// 1. Given - A folder located in a test directory
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)

        let context = MockContext(
            folderExistsHandler: { url in
                #expect(url == folder.location, "Should query the correct folder location.")
                return true
            }
        )
        context.called = []
        
        /// 2. When - Inspecting whether the folder exists
        let result = folder.exists(using: context)
        
        /// 3. Then - The folder does exist
        #expect(result)
        #expect(context.called == [.folderExists])
    }
    
    @Test("Verifies that a folder does not exist.")
    func testFolderDoesNotExist() throws {
        
        /// 1. Given - A folder located in a test directory
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)

        let context = MockContext(
            folderExistsHandler: { url in
                #expect(url == folder.location, "Should query the correct folder location.")
                return false
            }
        )
        context.called = []
        
        /// 2. When - Inspecting whether the folder exists
        let result = folder.exists(using: context)
        
        /// 3. Then - The folder does not exist
        #expect(!result)
        #expect(context.called == [.folderExists])
    }
}
