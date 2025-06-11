//
//  RemoveDirectoryTests.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation
import Testing

@Suite
struct RemoveDirectoryTests {
    
    @Test("It removes a directory using the correct URL.")
    func testRemoveDirectoryCalled() throws {
        
        let testURL = try #require(URL(string: "~/cleanup-dir"))
        
        let context = MockContext(removeDirectoryHandler: URLExpectation.asserting(
            testURL,
            message: "Should attempt to remove the correct directory."
        ))
        
        try context.removeDirectory(at: testURL)
        
        #expect(context.called.contains(.removeDirectory), "Expected `.removeDirectory` to be called.")
    }
    
    @Test("It throws an error if removal fails.")
    func testRemoveDirectoryThrows() throws {
        
        struct DummyError: Error {}
        let testURL = try #require(URL(string: "~/non-removable-dir"))

        let context = MockContext(removeDirectoryHandler: URLExpectation.throwing(
            testURL,
            message: "Should fail for non-removable directory.",
            error: DummyError()
        ))

        do {
            try context.removeDirectory(at: testURL)
            Issue.record("Expected error was not thrown.")
        } catch {
            #expect(error is DummyError)
        }

        #expect(context.called.contains(.removeDirectory))
    }
}
