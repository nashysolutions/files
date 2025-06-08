//
//  FileSystemDirectory.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation

/// Represents a well-known directory location within the app's sandboxed file system.
///
/// Each case corresponds to a specific iOS directory intended for storing different
/// kinds of data (e.g. user documents, cacheable files, app support files, or temporary data).
public enum FileSystemDirectory: Sendable {
    
    /// The user-accessible Documents directory.
    ///
    /// Use this for files that should be visible to the user or backed up to iCloud.
    case documents

    /// The Caches directory.
    ///
    /// Use this for files that can be recreated and don't need to be backed up.
    case caches

    /// The Application Support directory.
    ///
    /// Use this for app-internal files that should be backed up but are not user-facing.
    case applicationSupport

    /// The Temporary directory.
    ///
    /// Use this for short-lived files that can be deleted by the system at any time.
    case temporary

    /// Returns the corresponding `FileManager.SearchPathDirectory` for this case, or `nil` for `.temporary`.
    var searchPath: FileManager.SearchPathDirectory? {
        switch self {
        case .documents: .documentDirectory
        case .caches: .cachesDirectory
        case .applicationSupport: .applicationSupportDirectory
        case .temporary: nil
        }
    }

    /// Creates a `FileSystemFolderStore` using the current directory kind.
    ///
    /// - Parameter agent: The file system context used to resolve the directory location.
    /// - Returns: A configured `FileSystemFolderStore` targeting this directory kind.
    /// - Throws: An error if the directory cannot be resolved.
    public func folderStore<Agent: FileSystemContext>(using agent: Agent) throws -> FileSystemFolderStore<Agent> {
        try FileSystemFolderStore(
            agent: agent,
            folder: folder(using: agent),
            kind: self
        )
    }
}

private extension FileSystemDirectory {
    
    /// Resolves the `Folder` for this directory kind using the provided file system agent.
    ///
    /// - Parameter agent: The file system context used to resolve the location.
    /// - Returns: A `Folder` representing the resolved file system location.
    /// - Throws: An error if the location could not be resolved.
    func folder<Agent: FileSystemContext>(using agent: Agent) throws -> Folder {
        let location = try agent.url(for: self)
        return Folder(location: location)
    }
}
