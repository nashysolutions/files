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
/// resources and raw data using a specified folder, file system agent, and semantic directory kind.
///
/// This type is commonly used as a lightweight wrapper around a file system context and a base folder,
/// streamlining access to file operations within a single directory.
///
/// - Note: This type is generic over the `Agent`, which must conform to `FileSystemContext`.
public struct FileSystemFolderStore<Agent: FileSystemContext>: FileSystemOperations {
    
    /// The file system agent responsible for performing low-level operations such as read, write, delete, etc.
    public let agent: Agent

    /// The base folder representing the root location where files are stored.
    public let folder: Folder

    /// The semantic type of the folder (e.g. `.documents`, `.applicationSupport`).
    public let kind: FileSystemDirectory

    /// Creates a new `FileSystemFolderStore` by resolving a folder path for the given `kind`.
    ///
    /// This is useful when your application logic works in logical file spaces (e.g., app support, documents),
    /// and you want to perform file operations scoped to that directory.
    ///
    /// - Parameters:
    ///   - agent: The file system context used to perform operations.
    ///   - kind: The semantic directory kind (such as `.documents`, `.caches`, etc.) that will be resolved into a folder path.
    ///
    /// - Throws: An error if the agent fails to resolve the URL for the directory kind.
    public init(agent: Agent, kind: FileSystemDirectory) throws {
        self.agent = agent
        let url = try agent.url(for: kind)
        self.folder = Folder(location: url)
        self.kind = kind
    }
}
