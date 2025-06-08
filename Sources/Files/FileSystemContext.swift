//
//  FileSystemContext.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

/// A protocol for interacting with the file system to manage files (resources) and folders (directories).
public protocol FileSystemContext {
    
    /// Determines whether a file exists at the specified URL.
    /// - Parameter url: The URL to check for the presence of a file.
    /// - Returns: `true` if a file is found at the URL, otherwise `false`.
    func fileExists(at url: URL) -> Bool
    
    /// Determines whether a folder exists at the specified URL.
    /// - Parameter url: The URL to check for the presence of a folder.
    /// - Returns: `true` if a folder is found at the URL, otherwise `false`.
    func folderExists(at url: URL) -> Bool
    
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
    
    /// Writes data to a file at the specified URL with configurable write options.
    ///
    /// This method writes the provided data to the specified file. If the file exists, it will be overwritten unless
    /// write options dictate otherwise.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: The location to write the data to.
    ///   - options: Options to control the write behaviour (e.g., atomic writes).
    /// - Throws: An error if writing fails, such as due to permission issues or invalid paths.
    func write(_ data: Data, to url: URL, options: NSData.WritingOptions) throws

    /// Reads the contents of a file into memory.
    ///
    /// This method reads and returns the contents of the file located at the given URL.
    ///
    /// - Parameter url: The location of the file to read.
    /// - Returns: The data contained in the file.
    /// - Throws: An error if the file does not exist, is unreadable, or another read error occurs.
    func read(from url: URL) throws -> Data

    /// Resolves a base URL for a known system directory.
    ///
    /// This method translates a logical `FileSystemDirectory` enum into a concrete file system URL,
    /// such as the user documents directory, temporary directory, or application support folder.
    ///
    /// - Parameter directory: The logical directory to resolve.
    /// - Returns: The resolved file system URL.
    /// - Throws: An error if the directory cannot be resolved (e.g., access denied or not found).
    func url(for directory: FileSystemDirectory) throws -> URL
}

public extension FileSystemContext {
    
    /// Ensures that a folder (directory) exists at the specified URL, creating it if necessary. Therefore, this function does not throw if the folder already exists.
    /// - Parameter url: The location of the folder to check or create.
    /// - Throws: An error if the operation to create the folder fails.
    func createDirectoryIfNecessary(at url: URL) throws {
        if folderExists(at: url) == false {
            try createDirectory(at: url)
        }
    }
    
    /// Deletes a folder (directory) at the specified URL only if it exists.
    /// This function will not throw an error if the folder does not exist.
    /// - Parameter url: The location of the folder to check and delete.
    /// - Throws: An error if the operation to delete the folder fails.
    func deleteDirectoryIfExists(at url: URL) throws {
        if folderExists(at: url) == true {
            try deleteLocation(at: url)
        }
    }
}
