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
    
    /// Removes a folder (directory) at the specified URL.
    /// - Parameter url: The location where the folder should be created.
    /// - Throws: An error if the operation fails.
    func removeDirectory(at url: URL) throws
    
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

    /// Lists the contents of a directory at the specified URL.
    ///
    /// This method returns the URLs of the items contained in the directory located at the given URL.
    /// It mirrors the semantics of `FileManager.contentsOfDirectory(at:includingPropertiesForKeys:options:)`.
    ///
    /// - Parameters:
    ///   - url: The directory to enumerate.
    ///   - keys: Resource keys to prefetch for the returned URLs.
    ///   - options: Options that affect the enumeration behavior.
    /// - Returns: An array of URLs for the items in the directory.
    /// - Throws: An error if the directory cannot be read or enumerated.
    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey],
        options: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]
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

// MARK: - Error Mapping
public enum FileSystemError: Error {
    case alreadyExists(URL)
    case notFound(URL)
    case permissionDenied(URL)
    case invalidDestination(URL)
    case invalidSource(URL)
    case underlying(Error)
}

public extension FileSystemContext {
    
    /// Moves a resource, with optional overwrite behavior.
    /// - Parameters:
    ///   - fromURL: Source URL.
    ///   - toURL: Destination URL.
    ///   - overwrite: If true and destination exists, it will be removed before moving.
    func moveResource(from fromURL: URL, to toURL: URL, overwrite: Bool) throws {
        // Ensure source exists
        guard fileExists(at: fromURL) || folderExists(at: fromURL) else {
            throw FileSystemError.notFound(fromURL)
        }
        // Handle destination existence
        if fileExists(at: toURL) || folderExists(at: toURL) {
            if overwrite {
                do { try deleteLocation(at: toURL) } catch { throw mapFileManagerError(error, url: toURL) }
            } else {
                throw FileSystemError.alreadyExists(toURL)
            }
        }
        do { try moveResource(from: fromURL, to: toURL) } catch { throw mapFileManagerError(error, url: toURL) }
    }

    /// Copies a resource, with optional overwrite behavior.
    /// - Parameters:
    ///   - fromURL: Source URL.
    ///   - toURL: Destination URL.
    ///   - overwrite: If true and destination exists, it will be removed before copying.
    func copyResource(from fromURL: URL, to toURL: URL, overwrite: Bool) throws {
        // Ensure source exists
        guard fileExists(at: fromURL) || folderExists(at: fromURL) else {
            throw FileSystemError.notFound(fromURL)
        }
        // Handle destination existence
        if fileExists(at: toURL) || folderExists(at: toURL) {
            if overwrite {
                do { try deleteLocation(at: toURL) } catch { throw mapFileManagerError(error, url: toURL) }
            } else {
                throw FileSystemError.alreadyExists(toURL)
            }
        }
        do { try copyResource(from: fromURL, to: toURL) } catch { throw mapFileManagerError(error, url: toURL) }
    }

    /// Maps common file system errors to `FileSystemError` for clearer diagnostics.
    /// - Note: This provides a best-effort mapping and falls back to `.underlying`.
    private func mapFileManagerError(_ error: Error, url: URL) -> FileSystemError {
        let nsError = error as NSError
        switch (nsError.domain, nsError.code) {
        case (NSCocoaErrorDomain, NSFileWriteFileExistsError):
            return .alreadyExists(url)
        case (NSCocoaErrorDomain, NSFileNoSuchFileError):
            return .notFound(url)
        case (NSCocoaErrorDomain, NSFileReadNoPermissionError),
             (NSCocoaErrorDomain, NSFileWriteNoPermissionError):
            return .permissionDenied(url)
        default:
            return .underlying(error)
        }
    }
}

public extension FileSystemContext {
    
    /// Writes data to a file, enforcing `.atomic` by default.
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: Destination URL.
    ///   - options: Additional write options to combine with `.atomic` (default is empty set).
    func write(_ data: Data, to url: URL, options: NSData.WritingOptions = []) throws {
        var finalOptions = options
        finalOptions.insert(.atomic)
        try write(data, to: url, options: finalOptions)
    }
    
    /// Writes data only if it differs from the existing file contents, enforcing `.atomic` by default.
    ///
    /// This helper reduces unnecessary disk writes and avoids triggering superfluous file change notifications
    /// (e.g., for observers or backup systems) when the content is unchanged. It also helps preserve file metadata
    /// like modification dates when there is no content change.
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: Destination URL.
    ///   - options: Additional write options to combine with `.atomic` (default is empty set).
    /// - Returns: `true` if a write occurred, `false` if the existing contents were identical and no write was performed.
    @discardableResult
    func writeIfChanged(_ data: Data, to url: URL, options: NSData.WritingOptions = []) throws -> Bool {
        if fileExists(at: url) {
            do {
                let existing = try read(from: url)
                if existing == data { return false }
            } catch {
                // If we fail to read, fall through to writing and surface any write error.
            }
        }
        try write(data, to: url, options: options)
        return true
    }
}
