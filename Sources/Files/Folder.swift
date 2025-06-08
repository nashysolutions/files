//
//  Folder.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation

/// A concrete representation of a directory on disk.
///
/// `Folder` is a simple type that represents a directory by its URL and conforms to `Directory`.
/// It can be used as the root or container for file-based resource storage.
public struct Folder: Directory {
    
    /// The file system location of the folder.
    public let location: URL
    
    /// Creates a new `Folder` instance.
    ///
    /// - Parameter location: The URL representing the folder’s location on disk.
    public init(location: URL) {
        self.location = location
    }
}
