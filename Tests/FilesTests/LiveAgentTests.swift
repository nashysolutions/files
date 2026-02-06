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
    
    @Test("It correctly sums the total size of all regular files in a folder.")
    func testTotalSizeOfFiles() throws {

        // Given - A unique temporary folder and a store
        let agent = LiveAgent()
        let uniqueName = UUID().uuidString
        let store = try FileSystemFolderStore(agent: agent, kind: .temporary, subfolder: uniqueName)
        let testDir = store.folder.location
        try? agent.removeDirectory(at: testDir)
        if agent.folderExists(at: testDir) {
            Issue.record("Test setup failed: The test directory '\(testDir.path)' could not be deleted and still exists.")
        }
        defer { try? agent.removeDirectory(at: testDir) }
        try store.folder.createIfNecessary(using: agent)

        // When - Creating files of known size in the folder
        let data1 = Data(repeating: 1, count: 128)
        let data2 = Data(repeating: 2, count: 512)
        let data3 = Data() // Zero-byte
        try store.folder.createResource(filename: "file1.bin", with: data1, using: agent)
        try store.folder.createResource(filename: "file2.bin", with: data2, using: agent)
        try store.folder.createResource(filename: "file3.bin", with: data3, using: agent)
        
        // Then - The reported total matches the sum of their sizes
        let expectedTotal = Int64(data1.count + data2.count + data3.count)
        #expect(expectedTotal > 0)
        let actualTotal = try store.totalSizeOfFiles()
        #expect(actualTotal > 0)
        #expect(actualTotal == expectedTotal, "Total size should equal the sum of all file sizes: \(expectedTotal)")
    }
    
    @Test("It copies all files from a source folder to a destination folder.")
    func testCopyAllFiles() throws {
        // Given: Unique source and destination folders
        let agent = LiveAgent()
        let uniqueRoot = agent.testFolderLocation().appendingPathComponent(UUID().uuidString, isDirectory: true)
        let uniqueSrcName = "src"
        let uniqueDstName = "dst"
        let srcURL = uniqueRoot.appendingPathComponent(uniqueSrcName, isDirectory: true)
        let dstURL = uniqueRoot.appendingPathComponent(uniqueDstName, isDirectory: true)
        let dstFolder = MockFolder(location: dstURL)
        let store = try FileSystemFolderStore(agent: agent, kind: .temporary, subfolder: uniqueSrcName)
        defer { try? agent.removeDirectory(at: uniqueRoot) }
        try agent.createDirectory(at: srcURL)
        try agent.createDirectory(at: dstURL)
        // And: Several files in the source folder (use store.folder)
        let files = [
            ("one.txt", Data("one".utf8)),
            ("two.txt", Data("two".utf8)),
            ("three.txt", Data("three".utf8))
        ]
        for (name, data) in files {
            try store.folder.createResource(filename: name, with: data, using: agent)
        }
        // When: Copying all files from store.folder (source) to destination
        let copied = try store.copyAllFiles(to: dstFolder)
        #expect(copied == files.count, "Should report number of files copied")
        // Then: All files exist in the destination, with correct contents
        for (name, data) in files {
            let dstResource = dstFolder.resource(filename: name)
            let dstData = try dstResource.read(using: agent)
            #expect(dstData == data, "Copied file \(name) should match source data")
        }
    }

    @Test("It moves all files from a source folder to a destination folder, removing them from the source.")
    func testMoveAllFiles() throws {
        let agent = LiveAgent()

        // Make the store pick a unique subfolder so tests don't collide
        let uniqueSubfolder = UUID().uuidString
        let store = try FileSystemFolderStore(agent: agent, kind: .temporary, subfolder: uniqueSubfolder)

        // IMPORTANT: derive the source URL from the store
        let srcURL = store.folder.location
        let srcFolder = MockFolder(location: srcURL)

        // Put destination alongside source (same parent)
        let rootURL = srcURL.deletingLastPathComponent()
        let dstURL = rootURL.appendingPathComponent("dst", isDirectory: true)
        let dstFolder = MockFolder(location: dstURL)

        defer { try? agent.removeDirectory(at: rootURL) }

        try agent.createDirectory(at: srcURL)
        try agent.createDirectory(at: dstURL)

        // Ensure the destination folder is empty to prevent file name collision
        if agent.folderExists(at: dstURL) {
            let contents = try? FileManager.default.contentsOfDirectory(at: dstURL, includingPropertiesForKeys: nil)
            contents?.forEach { try? FileManager.default.removeItem(at: $0) }
        }

        struct File: StoredItem {
            typealias Folder = MockFolder
            let filename: String
            let enclosingFolder: MockFolder
            let data: Data
        }

        let files = [
            File(filename: "one.txt", enclosingFolder: srcFolder, data: Data("one".utf8)),
            File(filename: "two.txt", enclosingFolder: srcFolder, data: Data("two".utf8)),
            File(filename: "three.txt", enclosingFolder: srcFolder, data: Data("three".utf8))
        ]

        for file in files {
            try file.enclosingFolder.createResource(filename: file.filename, with: file.data, using: agent)
        }

        let moved = try store.moveFiles(matching: { _ in true }, to: dstFolder)
        #expect(moved == files.count)

        for file in files {
            let dstResource = dstFolder.resource(filename: file.filename)
            let dstData = try dstResource.read(using: agent)
            #expect(dstData == file.data)

            let srcResource = srcFolder.resource(filename: file.filename)
            let srcExists = srcResource.exists(using: agent)
            #expect(srcExists == false)
        }
    }
    
    @Test("It reports partial success and error if move fails in the middle (mocked context).")
    func testMoveFilesPartialFailureWithMock() throws {
        // Given: A mock context, folders, and files
        let srcURL = URL(fileURLWithPath: "/mock/src-mid-fail", isDirectory: true)
        let dstURL = URL(fileURLWithPath: "/mock/dst-mid-fail", isDirectory: true)

        let srcFolder = MockFolder(location: srcURL)
        let dstFolder = MockFolder(location: dstURL)

        let files: [(name: String, data: Data)] = [
            ("one.txt", Data("one".utf8)),
            ("two.txt", Data("two".utf8)),   // simulate error on this file
            ("three.txt", Data("three".utf8))
        ]

        // These are the URLs that directory enumeration should yield
        let srcFileURLs: [URL] = files.map { srcURL.appendingPathComponent($0.name) }
        
        // Removed block that sets .isRegularFile resource values because it's not supported in this mock context.
        // for url in srcFileURLs {
        //     var values = URLResourceValues()
        //     values.isRegularFile = true
        //     try? url.setResourceValues(values)
        // }

        // Track which files were moved
        var movedFiles: [(from: URL, to: URL)] = []

        let simulatedError = NSError(domain: "Mock", code: 999, userInfo: nil)

        // Set up the mock so file 2 fails
        let moveHandler: (URL, URL) throws -> Void = { from, to in
            if from.lastPathComponent == "two.txt" { throw simulatedError }
            movedFiles.append((from, to))
        }

        let context = MockContext(
            // Only the source folder and its files exist, destination files do not exist yet
            fileExistsHandler: { url in
                url == srcURL || srcFileURLs.contains(url)
            },
            folderExistsHandler: { url in url == srcURL || url == dstURL },
            moveResourceHandler: moveHandler,
            createDirectoryHandler: { _ in },
            contentsOfDirectoryHandler: { url, keys, options in
                // NOTE: This mock does not simulate .isRegularFile resource values, so the underlying logic must not depend on that for this test to work. If moveFiles relies on .isRegularFile, you will need a more advanced mocking strategy or real files.
                // Only return entries for the source folder
                guard url == srcURL else { return [] }
                return srcFileURLs
            }
        )

        // Create store
        struct TestStore: FileSystemOperations {
            let agent: MockContext
            let folder: MockFolder
            let srcFileURLs: [URL]

            func contents(
                includingPropertiesForKeys keys: [URLResourceKey] = [],
                options: FileManager.DirectoryEnumerationOptions = []
            ) throws -> [DirectoryEntry] {
                // Simulate three regular files
                return srcFileURLs.map { url in
                    let values = URLResourceValues()
                    // NOTE: .isRegularFile is not settable in test, so this test assumes moveFiles does not require it
                    return DirectoryEntry(url: url, resourceValues: values)
                }
            }

            func contents() throws -> [DirectoryEntry] {
                try contents(includingPropertiesForKeys: [], options: [])
            }
        }
        let store = TestStore(agent: context, folder: srcFolder, srcFileURLs: srcFileURLs)

        // When: Attempting to move files, simulating partial failure
        let names = Set(files.map(\.name))

        var thrownError: Error? = nil
        do {
            _ = try store.moveFiles(
                matching: { entry in names.contains(entry.url.lastPathComponent) },
                to: dstFolder
            )
            Issue.record("Expected error when moving 'two.txt'")
        } catch {
            thrownError = error
        }

        // Then: Only files before the error moved
        let expectedMoved = ["one.txt"]
        #expect(movedFiles.map { $0.from.lastPathComponent } == expectedMoved)
        #expect(thrownError != nil)
    }
    
    @Test("Integration: moves files using real file system")
    func testIntegrationMoveFilesRealFS() throws {
        let fileManager = FileManager.default
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("liveagent-integration-\(UUID().uuidString)", isDirectory: true)
        let src = root.appendingPathComponent("src", isDirectory: true)
        let dst = root.appendingPathComponent("dst", isDirectory: true)
        try fileManager.createDirectory(at: src, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: dst, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        // Write 3 files
        let files = [
            ("one.txt", Data("one".utf8)),
            ("two.txt", Data("two".utf8)),
            ("three.txt", Data("three".utf8))
        ]
        for (name, data) in files {
            let fileURL = src.appendingPathComponent(name)
            try data.write(to: fileURL)
        }
        // Move all files using real agent logic
        let agent = LiveAgent()
        let srcFolder = MockFolder(location: src)
        let dstFolder = MockFolder(location: dst)
        for (name, _) in files {
            let resource = MockResource(filename: name, enclosingFolder: srcFolder)
            try resource.move(to: dstFolder, using: agent)
        }

        // Assert all files are now in dst with correct contents, and missing from src
        for (name, data) in files {
            let dstFileURL = dst.appendingPathComponent(name)
            let srcFileURL = src.appendingPathComponent(name)
            let existsInDst = fileManager.fileExists(atPath: dstFileURL.path)
            let existsInSrc = fileManager.fileExists(atPath: srcFileURL.path)
            #expect(existsInDst, "File \(name) should exist in dst after move")
            #expect(!existsInSrc, "File \(name) should no longer exist in src after move")
            let actualData = try Data(contentsOf: dstFileURL)
            #expect(actualData == data, "File contents should match for \(name)")
        }
    }
}

