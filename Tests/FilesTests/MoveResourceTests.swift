//
//  MoveResourceTests.swift
//  files
//
//  Created by Robert Nash on 10/01/2025.
//

import Testing
import Foundation
import Files

@Suite
struct MoveResourceTests {
    
    @Test("It moves a file to the target directory successfully.")
    func testMovesFileSuccessfully() throws {
        
        /// 1. Given - File A in folder A
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let fileA = MockResource(filename: "ResourceA", enclosingFolder: folderA)
        let fromURL = fileA.location
        
        /// 2. And - Folder B as the target
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        let toURL = folderB.location.appending(path: fileA.filename)
        
        /// 3. And - A context that records the move
        let context = MockContext(moveResourceHandler: { from, to in
            #expect(from == fromURL, "Source URL should match the file's current location.")
            #expect(to == toURL, "Destination URL should be correctly constructed.")
        })

        /// 4. When - Performing the move
        try fileA.move(to: folderB, using: context)

        /// 5. Then - Only the move endpoint was called
        #expect(context.called == [.moveResource])
    }
    
    @Test("It throws an error when moving a file fails.")
    func testThrowsErrorWhenMoveFails() throws {
        
        /// 1. Given - File A in folder A
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let fileA = MockResource(filename: "ResourceA", enclosingFolder: folderA)
        let fromURL = fileA.location

        /// 2. And - Folder B as the target
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        let toURL = folderB.location.appending(path: fileA.filename)
        
        /// 3. And - A context that throws an error when moving
        let simulatedError = NSError(domain: "MockError", code: 1)
        let context = MockContext(moveResourceHandler: { from, to in
            #expect(from == fromURL, "Source URL should match the file's current location.")
            #expect(to == toURL, "Destination URL should be correctly constructed.")
            throw simulatedError
        })

        /// 4. When/Then - Expect an error to be thrown
        do {
            try fileA.move(to: folderB, using: context)
            Issue.record("Expected an error to be thrown.")
        } catch {
            #expect((error as NSError) == simulatedError, "Error should match simulated failure.")
        }

        /// 5. Then - Only the move endpoint was called
        #expect(context.called == [.moveResource])
    }
}
