//
//  CopyAllResourcesOperation.swift
//  files
//
//  Created by Robert Nash on 06/02/2026.
//

import Foundation

struct CopyAllResourcesOperation<Context: FileSystemOperations> {
    
    let context: Context
    
    func execute(to destination: some Directory) throws -> Int {
        try context.agent.createDirectoryIfNecessary(at: destination.location)
        let entries = try context.contents(includingPropertiesForKeys: [.isRegularFileKey, .nameKey], options: [])
        var copied = 0
        for entry in entries where entry.resourceValues.isRegularFile == true {
            let dst = destination.location.appendingPathComponent(entry.url.lastPathComponent, isDirectory: false)
            try context.agent.copyResource(from: entry.url, to: dst)
            copied += 1
        }
        return copied
    }
}
