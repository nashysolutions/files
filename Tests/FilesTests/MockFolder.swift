//
//  MockFolder.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Files

struct MockFolder: Directory {
    
    let location: URL
    
    func exists(using context: FileSystemContext) -> Bool {
        context.folderExists(at: location)
    }
}
