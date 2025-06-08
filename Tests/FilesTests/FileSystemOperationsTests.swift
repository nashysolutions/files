//
//  FileSystemOperationsTests.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation
import Testing
import Files

@Suite("FileSystemOperations")
struct FileSystemOperationsTests {

    private struct TestStore: FileSystemOperations {
        let agent: MockContext
        let folder: MockFolder
    }

    private let folder = MockFolder(location: URL(fileURLWithPath: "/mock"))

    @Test("exists returns true when the folder exists on disk.")
    func testFolderExists() throws {
        let context = MockContext(
            folderExistsHandler: URLExpectation.exact(
                folder.location,
                message: "Folder existence should be checked using the correct location."
            )
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        #expect(store.folderExists, "The folder should be reported as existing.")
        #expect(context.called == [.folderExists])
    }

    @Test("loadResource delegates to LoadResource utility.")
    func testLoadResource() throws {
        struct Model: Codable, Equatable { let id: Int }

        let expected = Model(id: 99)
        let encoded = try JSONEncoder().encode(expected)
        let fileURL = folder.location.appending(component: "file.json")

        let context = MockContext(
            readHandler: URLExpectation.returningData(
                fileURL,
                data: encoded,
                message: "File read should use correct path."
            )
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        let result: Model = try store.loadResource(filename: "file.json")

        #expect(result == expected, "The decoded model should match.")
        #expect(context.called == [.read])
    }

    @Test("deleteResource invokes the deletion handler.")
    func testDeleteResource() throws {
        let context = MockContext(
            fileExistsHandler: { _ in true },
            folderExistsHandler: { _ in true },
            deleteLocationHandler: { _ in }
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        try store.deleteResource(filename: "file.json")
        #expect(context.called == [.deleteLocation])
    }

    @Test("updateResource applies the mutation closure and saves.")
    func testUpdateResource() throws {
        struct Counter: Codable, Equatable { var value: Int }

        let initial = Counter(value: 10)
        let expected = Counter(value: 11)
        let encoded = try JSONEncoder().encode(initial)

        let fileURL = folder.location.appending(component: "counter.json")

        let context = MockContext(
            folderExistsHandler: URLExpectation.exact(
                folder.location,
                message: "Should verify that the directory exists before update."
            ),
            writeHandler: { data, url, _ in
                #expect(url == fileURL, "Written to the correct file.")
                let updated = try JSONDecoder().decode(Counter.self, from: data)
                #expect(updated == expected, "Updated model should reflect mutation.")
            },
            readHandler: URLExpectation.returningData(
                fileURL,
                data: encoded,
                message: "Should read existing file content correctly."
            )
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        try store.updateResource(filename: "counter.json") { (resource: inout Counter) in
            resource.value += 1
        }

        #expect(context.called.contains(.folderExists))
        #expect(context.called.contains(.read))
        #expect(context.called.contains(.write))
        #expect(context.called.count == 3)
    }

    @Test("saveData creates folder before saving data.")
    func testSaveData() throws {
        let fileURL = folder.location.appending(component: "file.data")
        let testData = Data("test".utf8)

        let context = MockContext(
            folderExistsHandler: URLExpectation.exact(
                folder.location,
                message: "Should check if the folder exists before saving data."
            ),
            writeHandler: { actualData, actualURL, _ in
                #expect(actualURL == fileURL, "Should write to the correct file location.")
                #expect(actualData == testData, "Written data should match the input.")
            }
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        try store.saveData(testData, withName: "file.data")

        let folderExistsCalls = context.called.filter { $0 == .folderExists }
        #expect(folderExistsCalls.count == 2, "folderExists should be called twice.")
        #expect(context.called.contains(.write))
    }

    @Test("loadData returns data if file exists.")
    func testLoadData() throws {
        let fileURL = folder.location.appending(component: "example.txt")
        let expectedData = Data("hello".utf8)

        let context = MockContext(
            folderExistsHandler: URLExpectation.exact(
                folder.location,
                message: "Should confirm folder exists before reading."
            ),
            readHandler: URLExpectation.returningData(
                fileURL,
                data: expectedData,
                message: "Should read data from the correct file location."
            )
        )

        let store = TestStore(agent: context, folder: folder)
        context.called = []

        let result = try store.loadData(named: "example.txt")

        #expect(result == expectedData, "Loaded data should match the expected value.")
        #expect(context.called == [.read])
    }
}

