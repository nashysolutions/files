//
//  CopyResourceTests.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

@Suite
struct CopyResourceTests {
    
    @Test("Successfully copies a resource to the target location.")
    func testCopyResourceSuccessfully() throws {
        
        /// 1. Given - A file (`file`) located in folder A.
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let file = MockResource(filename: "ResourceA", enclosingFolder: folderA)
        
        let filename = file.filename
        let originalLocation = file.location
        
        /// 2. And - A target folder (folder B) that the file will be copied into.
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        /// 3. And - A mock context with a copy handler that asserts input.
        let context = MockContext(copyResourceHandler:
            URLExpectation.moveOrCopy(
                expectedFrom: originalLocation,
                expectedTo: folderB.location.appending(path: filename),
                message: "Copy operation"
            )
        )
        
        /// 4. When - Copying the file to folder B
        try file.copy(to: folderB, using: context)
        
        /// 5. Then - The correct endpoint was invoked
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.copyResource), "The correct endpoint should have been called.")
    }

    @Test("It throws an error when copying fails.")
    func testCopyResourceThrowsError() throws {
        
        /// 1. Given - A file (`file`) located in folder A.
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let file = MockResource(filename: "ResourceA", enclosingFolder: folderA)
        
        let filename = file.filename
        let originalLocation = file.location
        
        /// 2. And - A target folder (folder B) to which the file will be copied.
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        /// 3. And - A simulated error to be thrown during the copy operation.
        let problem = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        /// 4. And - A context with a handler that asserts inputs and throws.
        let context = MockContext(
            copyResourceHandler: { from, to in
                try URLExpectation.moveOrCopy(
                    expectedFrom: originalLocation,
                    expectedTo: folderB.location.appending(path: filename),
                    message: "Copy operation"
                )(from, to)
                throw problem
            }
        )
        
        do {
            /// 5. When - Attempting to copy to folder B
            try file.copy(to: folderB, using: context)
            Issue.record("Expected error to be thrown.")
        } catch {
            /// 6. Then - The expected error is thrown
            #expect((error as NSError) == problem)
        }
        
        /// 7. Then - The correct endpoint was invoked
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.copyResource), "The correct endpoint should have been called.")
    }
}
