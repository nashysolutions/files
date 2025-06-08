//
//  LiveAgent.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

@testable import Files

/// A concrete implementation of `FileSystemContext` that uses the real file system.
/// Suitable for integration-style testing with temporary directories and live disk operations.
struct LiveAgent: FileSystemContext {
    
    private let liveContext = FileManager.default

    /// A temporary folder for test use.
    func testFolderLocation() -> URL {
        liveContext.temporaryDirectory.appendingPathComponent("Agent")
    }

    func fileExists(at url: URL) -> Bool {
        liveContext.fileExists(atPath: url.path())
    }

    func moveResource(from fromURL: URL, to toURL: URL) throws {
        fatalError("LiveAgent.moveResource is not yet implemented.")
    }

    func copyResource(from fromURL: URL, to toURL: URL) throws {
        fatalError("LiveAgent.copyResource is not yet implemented.")
    }

    func deleteLocation(at url: URL) throws {
        fatalError("LiveAgent.deleteLocation is not yet implemented.")
    }

    func createDirectory(at url: URL) throws {
        try liveContext.createDirectory(at: url, withIntermediateDirectories: true)
    }

    func removeDirectory(at url: URL) throws {
        try liveContext.removeItem(at: url)
    }

    func folderExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = liveContext.fileExists(atPath: url.path(), isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    func url(for directory: FileSystemDirectory) throws -> URL {
        if let path = directory.searchPath {
            guard let resolved = liveContext.urls(for: path, in: .userDomainMask).first else {
                throw LiveAgentError.unableToResolveSearchPath(path)
            }
            return resolved
        } else {
            return liveContext.temporaryDirectory
        }
    }

    func write(_ data: Data, to url: URL, options: NSData.WritingOptions) throws {
        try data.write(to: url, options: options)
    }

    func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
}

/// Error types specific to `LiveAgent`.
enum LiveAgentError: Error {
    case unableToResolveSearchPath(FileManager.SearchPathDirectory)
}
