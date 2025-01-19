//
//  FileSystemContext.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

/// A protocol for interacting with the file system to manage files (resources) and folders (directories).
public protocol FileSystemContext {
    
    /// Determines whether a file or directory exists at the specified URL.
    /// - Parameter url: The URL to check for the presence of a file or directory.
    /// - Returns: `true` if a file or directory is found at the URL, otherwise `false`.
    func locationExists(at url: URL) -> Bool
    
    /// Moves a file (resource) from one location to another.
    /// - Parameters:
    ///   - fromURL: The current location of the file.
    ///   - toURL: The destination location for the file.
    /// - Throws: An error if the operation fails.
    func moveResource(from fromURL: URL, to toURL: URL) throws
    
    /// Copies a file (resource) from one location to another.
    /// - Parameters:
    ///   - fromURL: The current location of the file.
    ///   - toURL: The destination location for the file.
    /// - Throws: An error if the operation fails.
    func copyResource(from fromURL: URL, to toURL: URL) throws
    
    /// Deletes a file or directory at the specified URL.
    ///
    /// This method removes the file or directory located at the given URL from the file system.
    /// If the file or directory does not exist, the method should throw an appropriate error.
    ///
    /// - Parameter url: The location of the file or directory to delete.
    /// - Throws: An error if the file or directory cannot be deleted, such as if the file or directory does not exist,
    ///           the caller lacks permissions, etc.
    func deleteLocation(at url: URL) throws
    
    /// Creates a folder (directory) at the specified URL.
    /// - Parameter url: The location where the folder should be created.
    /// - Throws: An error if the operation fails.
    func createDirectory(at url: URL) throws
}

public extension FileSystemContext {
    
    /// Ensures that a folder (directory) exists at the specified URL, creating it if necessary. Therefore, this function does not throw if the folder already exists.
    /// - Parameter url: The location of the folder to check or create.
    /// - Throws: An error if the operation to create the folder fails.
    func createDirectoryIfNecessary(at url: URL) throws {
        if locationExists(at: url) == false {
            try createDirectory(at: url)
        }
    }
    
    /// Deletes a folder (directory) at the specified URL only if it exists.
    /// This function will not throw an error if the folder does not exist.
    /// - Parameter url: The location of the folder to check and delete.
    /// - Throws: An error if the operation to delete the folder fails.
    func deleteDirectoryIfExists(at url: URL) throws {
        if locationExists(at: url) == true {
            try deleteLocation(at: url)
        }
    }
}
