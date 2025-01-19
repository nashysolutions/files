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
        
        /// 1. Given - FileA
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let fileA = MockResource(name: "ResourceA", enclosingFolder: folderA)
        
        let originalLocation = fileA.location
        
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        let toLocation = folderB.location.appending(path: fileA.name)
        
        let context = MockContext(moveResourceHandler: { from, to in
            
            /// 4. Then - The URLs here are ok.
            #expect(from == originalLocation)
            #expect(to == toLocation)
        })
        
        /// 2. When - We move to folderB
        try fileA.move(to: folderB, using: context)
        
        /// 6. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.moveResource), "The correct endpoint should have been called.")
    }
    
    @Test("It throws an error when moving a file fails.")
    func testThrowsErrorWhenMoveFails() throws {
        
        /// 1. Given - FileA
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let fileA = MockResource(name: "ResourceA", enclosingFolder: folderA)
        
        let originalLocation = fileA.location
        
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        let problem = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        let toLocation = folderB.location.appending(path: fileA.name)
        
        let context = MockContext(moveResourceHandler: { from, to in
            
            /// 4. Then - The URLs here are ok.
            #expect(from == originalLocation)
            #expect(to == toLocation)
            
            /// 3. And - we throw
            throw problem
        })
        
        do {
            /// 2. When - We move to folderB
            try fileA.move(to: folderB, using: context)
            Issue.record("Expected throw to occur.")
        } catch {
            /// 5. Then - An error is thrown
            #expect((error as NSError) == problem)
        }
        
        /// 7. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.moveResource), "The correct endpoint should have been called.")
    }
}
