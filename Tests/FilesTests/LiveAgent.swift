//
//  LiveAgent.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Files

struct LiveAgent: FileSystemContext {
    
    let liveContext = FileManager.default
    
    func testFolderLocation() -> URL {
        liveContext.temporaryDirectory.appendingPathComponent("Agent")
    }
    
    func locationExists(at url: URL) -> Bool {
        liveContext.fileExists(atPath: url.path())
    }
    
    func moveResource(from fromURL: URL, to toURL: URL) throws {}
    
    func copyResource(from fromURL: URL, to toURL: URL) throws {}
    
    func deleteLocation(at url: URL) throws {}
    
    func createDirectory(at url: URL) throws {
        try liveContext.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func removeDirectory(at url: URL) throws {
        try liveContext.removeItem(at: url)
    }
}
