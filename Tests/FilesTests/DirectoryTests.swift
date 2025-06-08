//
//  DirectoryTests.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

@Suite("FolderTests")
struct DirectoryTests {
    
    @Test("It creates a folder when it does not exist.")
    func testCreateDirectoryIfNecessary() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        
        let context = MockContext(
            folderExistsHandler: { _ in
                /// 1. Given - A folder that does not exist
                return false
            },
            createDirectoryHandler: { url in
                /// 3. Then - The URL here matches the location of the folder
                #expect(url == folder.location, "The correct path should be used.")
            })
        
        /// 2. When - We attempt to create the folder
        try folder.createIfNecessary(using: context)
        
        /// 4. Then - These endpoints are called
        #expect(context.called == [.folderExists, .createDirectory])
    }

    @Test("It throws an error when create fails.")
    func testCreateDirectoryFailure() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        
        let error = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        let context = MockContext(
            folderExistsHandler: { _ in
                /// 1. Given - A folder that does not exist
                return false
            },
            createDirectoryHandler: { url in
                /// 4. Then - The URL here matches the location of the folder
                #expect(url == folder.location, "The correct path should be used.")
                
                /// 2. And - An error is thrown when attempting to create
                throw error
            }
        )
        
        #expect(performing: {
            /// 3. When - Attempting to create the directory
            try folder.createIfNecessary(using: context)
        }, throws: {
            /// 5. Then - An error is thrown
            return ($0 as NSError) == error
        })
        
        /// 6. Then - These endpoints are called
        #expect(context.called == [.folderExists, .createDirectory])
    }
    
    @Test("Create is not attempted when the folder already exists.")
    func testDoNotCreateDirectory() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        
        let context = MockContext(
            folderExistsHandler: { _ in
                /// 1. Given - A folder that already exists
                return true
            })

        try folder.createIfNecessary(using: context)
        
        #expect(context.called == [.folderExists], "Only folder existence should be checked; creation must not be attempted.")
    }
    
    @Test("It successfully deletes a folder.")
    func testDeleteDirectory() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        
        let context = MockContext(
            folderExistsHandler: { _ in
                /// 1. Given - A folder that exists
                return true
            },
            deleteLocationHandler: { url in
                /// 3. Then - The URL here matches the location of the folder
                #expect(url == folder.location, "The correct path should be used.")
            }
        )
        
        /// 2. When - Deleting the folder
        try folder.deleteIfExists(using: context)
        
        /// 4. Then - These endpoints are called
        #expect(context.called == [.folderExists, .deleteLocation])
    }
    
    @Test("It throws an error if delete fails.")
    func testDeleteDirectoryFailure() throws {
        
        let location = try #require(URL(string: "~/test-directory"))
        let folder = MockFolder(location: location)
        
        let error = NSError(domain: "MockError", code: 1, userInfo: nil)
        
        let context = MockContext(
            folderExistsHandler: { _ in
                /// 1. Given - A folder that exists
                return true
            },
            deleteLocationHandler: { _ in
                /// 2. And - An error is thrown when attempting to delete
                throw error
            }
        )
        
        #expect(performing: {
            /// 3. When - Deleting the folder
            try folder.deleteIfExists(using: context)
        }, throws: {
            /// 4. Then - An error is thrown
            return ($0 as NSError) == error
        })
        
        /// 5. Then - These endpoints are called
        #expect(context.called == [.folderExists, .deleteLocation])
    }
    
    @Test("It creates a resource with the correct name and enclosing folder.")
    func testResourceCreation() throws {
        
        // 1. Given - A mock folder and resource name
        let folder = MockFolder(location: URL(fileURLWithPath: "/test-folder"))
        let resourceName = "test-file.txt"

        // 2. When - We create a resource using `resource(named:)`
        let resource = folder.resource(filename: resourceName)

        // 3. Then - Verify the resource properties
        #expect(resource.filename == resourceName, "The resource should have the correct name.")
        #expect(resource.enclosingFolder.location == folder.location, "The enclosing folder should match the folder.")
    }
}
