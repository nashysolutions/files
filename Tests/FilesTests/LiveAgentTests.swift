//
//  LiveAgentTests.swift
//  files
//
//  Created by Robert Nash on 10/01/2025.
//

import Foundation
import Testing

@testable import Files

// Ensures tests execute sequentially to avoid race conditions with the file system
@globalActor actor TestActor {
    static let shared = TestActor()
}

@TestActor
@Suite("LiveAgentTests")
struct LiveAgentTests {
    
    @Test("It writes data to a file and reads it back successfully.")
    func testWriteAndReadData() throws {
        // 1. Given - A live file system agent and a temporary folder
        let agent = LiveAgent()
        let folder = MockFolder(location: agent.testFolderLocation())
        try agent.createDirectory(at: folder.location)

        // 2. And - A resource and test data to write
        let file = MockResource(filename: "Resource", enclosingFolder: folder)
        let testData = try #require("Test content".data(using: .utf8))

        defer {
            // Cleanup - remove test directory regardless of test outcome
            try? agent.removeDirectory(at: folder.location)
        }

        // 3. When - Writing data to disk
        try file.write(data: testData, using: agent)

        // 4. Then - Reading it back yields the same content
        let readData = try file.read(using: agent)
        #expect(readData == testData, "The data read should match the data written.")
    }

    @Test("It verifies that a resource is created and exists in the folder.")
    func testCreateResourceSuccessfully() throws {
        struct Folder: Directory {
            let location: URL
        }

        struct Resource: StoredItem {
            let filename: String
            let enclosingFolder: Folder
        }

        // 1. Given - A live agent and a folder location
        let agent = LiveAgent()
        let folder = Folder(location: agent.testFolderLocation())

        defer {
            // Cleanup - always remove the test folder
            try? agent.removeDirectory(at: folder.location)
        }

        // 2. And - A file name and content to write
        let name = "Resource"
        let testData = try #require("Test content".data(using: .utf8))
        let resource = Resource(filename: name, enclosingFolder: folder)

        // 3. When - We write a file into the folder
        try folder.createResource(filename: name, with: testData, using: agent)

        // 4. Then - The file should now exist
        #expect(resource.exists(using: agent), "The resource should exist after creation.")
    }

    @Test("It throws an error when reading a nonexistent file.")
    func testReadNonexistentFileThrows() throws {
        let agent = LiveAgent()
        let folder = MockFolder(location: agent.testFolderLocation())
        let file = MockResource(filename: "no-such-file", enclosingFolder: folder)
        defer { try? agent.removeDirectory(at: folder.location) }
        do {
            _ = try file.read(using: agent)
            Issue.record("Expected error when reading nonexistent file.")
        } catch {
            #expect(true, "Caught expected error: \(error)")
        }
    }

    @Test("It throws an error when deleting a nonexistent file.")
    func testDeleteNonexistentFileThrows() throws {
        let agent = LiveAgent()
        let folder = MockFolder(location: agent.testFolderLocation())
        let file = MockResource(filename: "no-such-file", enclosingFolder: folder)
        defer { try? agent.removeDirectory(at: folder.location) }
        do {
            try file.delete(using: agent)
            Issue.record("Expected error when deleting nonexistent file.")
        } catch {
            #expect(true, "Caught expected error: \(error)")
        }
    }

    @Test("It throws an error when decoding invalid data.")
    func testDecodeInvalidDataThrows() throws {
        struct Folder: Directory { let location: URL }
        struct Corrupt: Codable { let broken: Int }
        let agent = LiveAgent()
        let folder = Folder(location: agent.testFolderLocation())
        let name = "corrupt.json"
        let resource = folder.resource(filename: name)
        let invalidData = try #require("not-a-json-object".data(using: .utf8))
        defer { try? agent.removeDirectory(at: folder.location) }
        try folder.createIfNecessary(using: agent)
        try invalidData.write(to: resource.location)
        do {
            let loader = LoadResource(agent: agent)
            _ = try loader.loadResource(named: name, location: folder) as Corrupt
            Issue.record("Expected error when decoding invalid data.")
        } catch {
            #expect(true, "Caught expected error: \(error)")
        }
    }
}
