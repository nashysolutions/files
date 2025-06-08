//
//  MockContext.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

final class MockContext: FileSystemContext {
    
    enum Endpoint {
        case fileExists
        case folderExists
        case moveResource
        case copyResource
        case deleteLocation
        case createDirectory
        case write
        case read
    }
    
    var called: [Endpoint] = []
    
    var fileExistsHandler: ((URL) -> Bool)?
    var folderExistsHandler: ((URL) -> Bool)?
    var moveResourceHandler: ((URL, URL) throws -> Void)?
    var copyResourceHandler: ((URL, URL) throws -> Void)?
    var deleteLocationHandler: ((URL) throws -> Void)?
    var createDirectoryHandler: ((URL) throws -> Void)?
    var directoryURLHandler: ((FileSystemDirectory) throws -> URL)?
    var writeHandler: ((Data, URL, NSData.WritingOptions) throws -> Void)?
    var readHandler: ((URL) throws -> Data)?
    
    init(
        fileExistsHandler: ((URL) -> Bool)? = nil,
        folderExistsHandler: ((URL) -> Bool)? = nil,
        moveResourceHandler: ((URL, URL) throws -> Void)? = nil,
        copyResourceHandler: ((URL, URL) throws -> Void)? = nil,
        deleteLocationHandler: ((URL) throws -> Void)? = nil,
        createDirectoryHandler: ((URL) throws -> Void)? = nil,
        directoryURLHandler: ((FileSystemDirectory) throws -> URL)? = nil,
        writeHandler: ((Data, URL, NSData.WritingOptions) throws -> Void)? = nil,
        readHandler: ((URL) throws -> Data)? = nil
    ) {
        self.fileExistsHandler = fileExistsHandler
        self.folderExistsHandler = folderExistsHandler
        self.moveResourceHandler = moveResourceHandler
        self.copyResourceHandler = copyResourceHandler
        self.deleteLocationHandler = deleteLocationHandler
        self.createDirectoryHandler = createDirectoryHandler
        self.directoryURLHandler = directoryURLHandler
        self.writeHandler = writeHandler
        self.readHandler = readHandler
    }

    func fileExists(at url: URL) -> Bool {
        called.append(.fileExists)
        return fileExistsHandler?(url) ?? false
    }
    
    func folderExists(at url: URL) -> Bool {
        called.append(.folderExists)
        return folderExistsHandler?(url) ?? false
    }
    
    func moveResource(from fromURL: URL, to toURL: URL) throws {
        called.append(.moveResource)
        try moveResourceHandler?(fromURL, toURL)
    }
    
    func copyResource(from fromURL: URL, to toURL: URL) throws {
        called.append(.copyResource)
        try copyResourceHandler?(fromURL, toURL)
    }
    
    func deleteLocation(at url: URL) throws {
        called.append(.deleteLocation)
        try deleteLocationHandler?(url)
    }
    
    func createDirectory(at url: URL) throws {
        called.append(.createDirectory)
        try createDirectoryHandler?(url)
    }
    
    func write(_ data: Data, to url: URL, options: NSData.WritingOptions) throws {
        called.append(.write)
        try writeHandler?(data, url, options)
    }

    func read(from url: URL) throws -> Data {
        called.append(.read)
        return try readHandler?(url) ?? Data()
    }
    
    func url(for directory: FileSystemDirectory) throws -> URL {
        if let handler = directoryURLHandler {
            return try handler(directory)
        }
        return URL(fileURLWithPath: "/mock/\(directory)") // fallback stub
    }
}
