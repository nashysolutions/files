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
        let file = MockResource(filename: "Resource", enclosingFolder: folder)

        /// 2. And - A mock context that asserts deletion input
        let context = MockContext(
            deleteLocationHandler: URLExpectation.asserting(
                file.location,
                message: "Should request deletion of the expected file."
            )
        )

        /// 3. When - We delete the file
        try file.delete(using: context)

        /// 4. Then - These endpoints are called
        #expect(context.called == [.deleteLocation], "Should only call the deleteLocation endpoint.")
    }
    
    @Test("It throws an error when resource deletion fails.")
    func testThrowsErrorOnDeletionFailure() throws {
        
        /// 1. Given - A file
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        let file = MockResource(filename: "Resource", enclosingFolder: folder)

        /// 2. And - A simulated error to throw
        let problem = NSError(domain: "MockError", code: 1, userInfo: nil)

        /// 3. And - A context that validates and throws on deletion
        let context = MockContext(
            deleteLocationHandler: URLExpectation.throwing(
                file.location,
                message: "File deletion should target the correct file location.",
                error: problem
            )
        )

        /// 4. When/Then - Deleting the file throws the expected error
        do {
            try file.delete(using: context)
            Issue.record("Expected deletion to throw an error, but it did not.")
        } catch {
            #expect((error as NSError) == problem)
        }

        /// 5. And - The delete endpoint was invoked
        let endpoints = context.called
        #expect(endpoints.count == 1)
        #expect(endpoints.contains(.deleteLocation), "The correct endpoint should have been called.")
    }
    
    @Test("It throws when attempting to delete a file that does not exist.")
    func testDeleteMissingFileThrows() throws {

        /// 1. Given - A file path pointing to a missing file
        let location = try #require(URL(string: "~/missing-file"))
        let folder = MockFolder(location: location)

        /// 2. And - Prepare the file URL first (do not keep the file alive yet)
        let filename = "ghost.txt"
        let fileURL = folder.location.appending(component: filename, directoryHint: .notDirectory)

        /// 3. And - A context that throws when delete is attempted
        let notFoundError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError)
        let context = MockContext(
            deleteLocationHandler: URLExpectation.throwing(
                fileURL,
                message: "Should try to delete the correct file path.",
                error: notFoundError
            )
        )

        /// 4. And - Now create the file *after* the context

        /// 5. When/Then - Deleting throws the expected error
        #expect(performing: {
            let file = MockResource(filename: filename, enclosingFolder: folder)
            try file.delete(using: context)
        }, throws: {
            let err = $0 as NSError
            return err.domain == NSCocoaErrorDomain && err.code == NSFileNoSuchFileError
        })

        /// 6. And - The endpoint was still invoked
        #expect(context.called == [.deleteLocation])
    }
}
