//
//  LiveAgentTests.swift
//  files
//
//  Created by Robert Nash on 10/01/2025.
//

import Foundation
import Testing
import Files

// We need the tests to be synchronous because we 1.create 2.test 3.destroy folders
@globalActor actor TestActor {
    static let shared = TestActor()
}

@TestActor // Makes tests synchronous
@Suite("LiveAgentTests") struct LiveAgentTests {
    
    @Test("Should successfully write data to a file and read it back.")
    func writeAndReadData() throws {
        
        let agent = LiveAgent()
        
        /// 1. Given - A folder location on disk.
        let folder = MockFolder(location: agent.testFolderLocation())
        try agent.createDirectory(at: folder.location)
        
        let file = MockResource(name: "Resource", enclosingFolder: folder)
        let testData = try #require("Test content".data(using: .utf8))
        
        /// 2. When - Writing data to this location.
        try file.write(data: testData)
        
        /// 3. And - Reading the data back from that location.
        let readData = try file.read()
        
        /// 4. Then - The written and read data should match.
        #expect(readData == testData, "Data should match.")
        
        /// Clean up
        try agent.removeDirectory(at: folder.location)
    }
    
    @Test("It verifies that a resource is successfully created within a specified folder.")
    func testCreateResourceSuccessfully() async throws {
        
        struct Folder: Directory {
            let location: URL
        }
        
        struct Resource: File {
            let name: String
            let enclosingFolder: Folder
        }
        
        /// 1. Given - A file system context
        let agent = LiveAgent()
        
        /// 2. And - a valid folder location
        let folder = Folder(location: agent.testFolderLocation())
        
        let testData = try #require("Test content".data(using: .utf8))
        let name = "Resource"
        let resource = Resource(name: name, enclosingFolder: folder)
        
        /// 3. When - we create a resource within that folder
        try folder.createResource(named: name, with: testData, using: agent)
        
        /// 4. Then - the resource is created
        #expect(resource.exists(using: agent))
        
        /// Clean up
        try agent.removeDirectory(at: folder.location)
    }
}
