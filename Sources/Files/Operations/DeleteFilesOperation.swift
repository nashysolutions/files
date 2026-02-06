//
//  DeleteFilesOperation.swift
//  files
//
//  Created by Robert Nash on 06/02/2026.
//

import Foundation

struct DeleteFilesOperation<Context: FileSystemOperations> {
    
    let context: Context
    
    func execute(matching shouldDelete: (DirectoryEntry) -> Bool) throws -> Int {
        let entries = try context.contents(includingPropertiesForKeys: [.isRegularFileKey, .nameKey], options: [])
        var deleted = 0
        for entry in entries where shouldDelete(entry) {
            try context.agent.deleteLocation(at: entry.url)
            deleted += 1
        }
        return deleted
    }
}
