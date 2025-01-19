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
    
    @Test("It successfully copies a resource to the target location.")
    func testCopyResourceSuccessfully() throws {
        
        /// 1. Given - FileA
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let file = MockResource(name: "ResourceA", enclosingFolder: folderA)
        
        let filename = file.name
        let originalLocation = file.location
        
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        let context = MockContext(copyResourceHandler: { from, to in
            
            /// 3. And - we don't throw
            
            /// 4. Then - The URLs here are ok.
            #expect(from == originalLocation)
            #expect(to == folderB.location.appending(path: filename))
        })
        
        /// 2. When - We copy to folderB
        try file.copy(to: folderB, using: context)
        
        /// 5. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.copyResource), "The correct endpoint should have been called.")
    }

    @Test("It throws an error when copying fails.")
    func testCopyResourceThrowsError() throws {
        
        /// 1. Given - FileA
        let locationA = try #require(URL(string: "~/test-directory-a"))
        let folderA = MockFolder(location: locationA)
        let file = MockResource(name: "ResourceA", enclosingFolder: folderA)
        
        let filename = file.name
        let originalLocation = file.location
        
        let locationB = try #require(URL(string: "~/test-directory-b"))
        let folderB = MockFolder(location: locationB)
        
        let problem = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        let context = MockContext(copyResourceHandler: { from, to in
            
            /// 4. Then - The URLs here are ok.
            #expect(from == originalLocation)
            #expect(to == folderB.location.appending(path: filename))
            
            /// 3. And - we throw
            throw problem
        })
        
        do {
            /// 2. When - We copy to folderB
            try file.copy(to: folderB, using: context)
            Issue.record("Expected error to be thrown.")
        } catch {
            /// 5. Then - An error is thrown
            #expect((error as NSError) == problem)
        }
        
        /// 6. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.copyResource), "The correct endpoint should have been called.")
    }
}
