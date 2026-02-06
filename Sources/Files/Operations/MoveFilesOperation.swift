//
//  MoveFilesOperation.swift
//  files
//
//  Created by Robert Nash on 06/02/2026.
//

import Foundation

struct MoveFilesOperation<Context: FileSystemOperations> {
    
    let context: Context
    
    func execute(matching shouldMove: (DirectoryEntry) -> Bool, to destination: some Directory) throws -> Int {
        try context.agent.createDirectoryIfNecessary(at: destination.location)
        let entries = try context.contents(includingPropertiesForKeys: [.isRegularFileKey, .nameKey], options: [])
        var moved = 0
        for entry in entries where shouldMove(entry) {
            let dst = destination.location.appendingPathComponent(entry.url.lastPathComponent, isDirectory: false)
            try context.agent.moveResource(from: entry.url, to: dst)
            moved += 1
        }
        return moved
    }
}
