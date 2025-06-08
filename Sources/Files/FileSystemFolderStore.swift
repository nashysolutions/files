//
//  FileSystemFolderStore.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation

/// A concrete implementation of `FileSystemOperations` that performs file system tasks within a specific directory.
///
/// `FileSystemFolderStore` provides a typed interface for saving, loading, updating, and deleting
/// resources and data using a specified folder, agent, and directory kind.
///
/// - Note: This type is generic over the `Agent`, which must conform to `FileSystemContext`.
public struct FileSystemFolderStore<Agent: FileSystemContext>: FileSystemOperations {
    
    /// The file system agent responsible for performing low-level operations.
    public let agent: Agent

    /// The folder representing the root location where files are stored.
    public let folder: Folder

    /// The kind of directory this store operates in (e.g., `.documents`, `.caches`).
    public let kind: FileSystemDirectory

    /// Creates a new `FileSystemFolderStore`.
    ///
    /// - Parameters:
    ///   - agent: The file system context used to perform operations.
    ///   - folder: The folder representing the target directory.
    ///   - kind: The high-level directory type (e.g., `.documents`, `.caches`).
    public init(agent: Agent, folder: Folder, kind: FileSystemDirectory) {
        self.agent = agent
        self.folder = folder
        self.kind = kind
    }
}
