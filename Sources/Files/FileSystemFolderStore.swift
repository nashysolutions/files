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


    /// Creates a `FileSystemFolderStore` scoped to an optional subfolder inside the specified base directory kind.
    ///
    /// This is useful for segmenting files within a known directory, such as creating a `temp/images` folder.
    /// If `subfolder` is `nil`, the base directory is used directly.
    ///
    /// - Parameters:
    ///   - agent: The file system agent used for performing file system operations.
    ///   - kind: The semantic directory kind (e.g., `.temporary`, `.caches`).
    ///   - subfolder: An optional subdirectory name inside the specified `kind`.
    /// - Throws: An error if the base directory cannot be resolved or the subfolder cannot be created.
    public init(agent: Agent, kind: FileSystemDirectory, subfolder: String? = nil) throws {
        self.agent = agent
        self.kind = kind

        let baseURL = try agent.url(for: kind)
        let finalURL = subfolder.map {
            baseURL.appendingPathComponent($0, isDirectory: true)
        } ?? baseURL

        try agent.createDirectoryIfNecessary(at: finalURL)
        self.folder = Folder(location: finalURL)
    }
}
