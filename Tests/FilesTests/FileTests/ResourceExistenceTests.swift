//
//  ResourceExistenceTests.swift
//  files
//
//  Created by Robert Nash on 10/01/2025.
//

import Foundation
import Testing
import Files

@Suite
struct ResourceExistenceTests {
    
    @Test("Verifies that a file exists.")
    func testFileExists() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(name: "Resource", enclosingFolder: folder)
        
        let context = MockContext(locationExistsHandler: { location in
            
            /// 3. Then - The URL here matches the location of the file.
            #expect(location == file.location, "The correct path should be used.")
            
            /// 1. Given - A file that already exists
            return true
        })

        /// 2. When - Inspecting the location of the file
        let result = file.exists(using: context)
        
        /// 4. Then - The file does exist
        #expect(result)
        
        /// 5. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.locationExists), "The correct endpoint should have been called.")
    }
    
    @Test("Verifies that a file does not exist.")
    func testFileDoesNotExists() async throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(name: "Resource", enclosingFolder: folder)
        
        let context = MockContext(locationExistsHandler: { location in
            
            /// 3. Then - The URL here matches the location of the file
            #expect(location == file.location, "The correct path should be used.")
            
            /// 1. Given - A file that does not already exists
            return false
        })

        /// 2. When - Inspecting the location of the file
        let result = file.exists(using: context)
        
        /// 4. Then - The file does exist
        #expect(!result)
        
        /// 5. Then - These endpoints are called
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.locationExists), "The correct endpoint should have been called.")
    }
}
