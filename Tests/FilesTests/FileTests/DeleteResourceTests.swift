//
//  DeleteResourceTests.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

@Suite
struct DeleteResourceTests {
    
    @Test("It deletes a resource successfully when no errors occur.")
    func testDeletesResourceSuccessfully() async throws {
        
        /// 1. Given - A file
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(name: "Resource", enclosingFolder: folder)
        
        let originalLocation = file.location
        
        let context = MockContext(deleteLocationHandler: { url in
            
            /// 3. Then - The URL here matches the location of the file.
            #expect(url == originalLocation)
        })
        
        /// 2. When - We delete the file
        try file.delete(using: context)
        
        /// 4. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.deleteLocation), "The correct endpoint should have been called.")
    }
    
    @Test("It throws an error when resource deletion fails.")
    func testThrowsErrorOnDeletionFailure() throws {
        
        /// 1. Given - A file
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(name: "Resource", enclosingFolder: folder)
        
        let originalLocation = file.location
        
        let problem = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        let context = MockContext(deleteLocationHandler: { url in
            
            /// 4. Then - The URL here matches the location of the file.
            #expect(url == originalLocation)
            
            /// 3. And - we throw
            throw problem
        })
        
        do {
            /// 2. When - We delete the file
            try file.delete(using: context)
            Issue.record("Expecting the deletion to throw an error, but it didn't.")
        } catch {
            // 5. Then - the error matches what was thrown
            #expect((error as NSError) == problem)
        }
        
        /// 6. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.deleteLocation), "The correct endpoint should have been called.")
    }
}
