//
//  FileSystemFolderStoreTests.swift
//  files
//
//  Created by Robert Nash on 14/06/2025.
//

import Foundation
import Testing
import Files

@Suite("FileSystemFolderStoreTests")
struct FileSystemFolderStoreTests {
    
    @Test("Initialises with base directory only")
    func testBaseDirectoryOnly() throws {
        let base = try #require(URL(string: "/base"))
        var capturedURL: URL?

        let context = MockContext(
            createDirectoryHandler: { url in capturedURL = url },
            directoryURLHandler: { _ in base }
        )
        
        let store = try FileSystemFolderStore(agent: context, kind: .documents)
        
        #expect(store.folder.location == base)
        #expect(capturedURL == base)
        #expect(context.called == [.folderExists, .createDirectory])
    }

    @Test("Initialises with flat subfolder")
    func testFlatSubfolder() throws {
        let base = try #require(URL(string: "/base"))
        var capturedURL: URL?

        let context = MockContext(
            createDirectoryHandler: { url in capturedURL = url },
            directoryURLHandler: { _ in base }
        )
        
        let store = try FileSystemFolderStore(agent: context, kind: .temporary, subfolder: "images")
        
        #expect(store.folder.location.path == "/base/images")
        #expect(capturedURL?.path == "/base/images")
        #expect(context.called == [.folderExists, .createDirectory])
    }

    @Test("Initialises with nested subfolder path")
    func testNestedSubfolder() throws {
        let base = try #require(URL(string: "/base"))
        var capturedURL: URL?

        let context = MockContext(
            createDirectoryHandler: { url in capturedURL = url },
            directoryURLHandler: { _ in base }
        )

        let store = try FileSystemFolderStore(agent: context, kind: .applicationSupport, subfolder: "a/b/c")
        
        #expect(store.folder.location.path == "/base/a/b/c")
        #expect(capturedURL?.path == "/base/a/b/c")
        #expect(context.called == [.folderExists, .createDirectory])
    }

    @Test("Skips subfolder logic if nil")
    func testNilSubfolderUsesBaseOnly() throws {
        let base = try #require(URL(string: "/only-base"))
        var capturedURL: URL?

        let context = MockContext(
            createDirectoryHandler: { url in capturedURL = url },
            directoryURLHandler: { _ in base }
        )

        let store = try FileSystemFolderStore(agent: context, kind: .caches, subfolder: nil)

        #expect(store.folder.location.path == "/only-base")
        #expect(capturedURL?.path == "/only-base")
        #expect(context.called == [.folderExists, .createDirectory])
    }
}
