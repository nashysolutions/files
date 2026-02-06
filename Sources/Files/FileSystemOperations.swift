//
//  FileSystemOperations.swift
//  files
//
//  Created by Robert Nash on 16/01/2025.
//

import Foundation

/// A protocol that defines file system operations for working with data and resources in a directory.
///
/// Types conforming to `FileSystemOperations` must provide a directory (`folder`) and an agent
/// that performs file system interactions (`agent`).
public protocol FileSystemOperations {
    
    /// The file system agent used to interact with the storage medium.
    associatedtype Agent: FileSystemContext

    /// The type of folder used as the root for storing and retrieving data.
    associatedtype Folder: Directory
        
    /// The folder where data is stored.
    var folder: Folder { get }

    /// The file system agent used to perform read/write/delete operations.
    var agent: Agent { get }
    
    /// Saves an encodable resource to disk.
    ///
    /// - Parameters:
    ///   - resource: The resource to save.
    ///   - name: The filename to save the resource under.
    /// - Throws: An error if the resource cannot be saved.
    func saveResource<Resource: Encodable>(_ resource: Resource, filename name: String) throws

    /// Loads a decodable resource from disk.
    ///
    /// - Parameter filename: The name of the file to load.
    /// - Returns: The decoded resource.
    /// - Throws: An error if the resource cannot be loaded.
    func loadResource<Resource: Decodable>(filename: String) throws -> Resource

    /// Deletes a resource from disk.
    ///
    /// - Parameter filename: The name of the file to delete.
    /// - Throws: An error if the resource cannot be deleted.
    func deleteResource(filename: String) throws

    /// Loads, modifies, and re-saves a codable resource.
    ///
    /// - Parameters:
    ///   - name: The name of the file to update.
    ///   - modify: A closure that receives an `inout` reference to the resource for modification.
    /// - Throws: An error if the resource cannot be loaded, modified, or saved.
    func updateResource<Resource: Codable>(filename name: String, modify: (inout Resource) -> Void) throws

    /// Saves raw `Data` to disk.
    ///
    /// - Parameters:
    ///   - data: The data to save.
    ///   - name: The name of the file to save to.
    /// - Throws: An error if the data cannot be saved.
    func saveData(_ data: Data, withName name: String) throws

    /// Loads raw `Data` from disk.
    ///
    /// - Parameter name: The name of the file to load.
    /// - Returns: The loaded data.
    /// - Throws: An error if the data cannot be loaded.
    func loadData(named name: String) throws -> Data

    /// Lists the contents of the store's folder and materializes requested resource values.
    ///
    /// - Parameters:
    ///   - keys: Resource keys to prefetch and materialize for each URL. Defaults to an empty list.
    ///   - options: Enumeration options that affect which items are returned and how. Defaults to an empty set.
    /// - Returns: An array of `DirectoryEntry` values for each item in the folder.
    /// - Throws: An error if the directory does not exist, is not a directory, or cannot otherwise be accessed or enumerated (for example, due to permissions).
    func contents(
        includingPropertiesForKeys keys: [URLResourceKey],
        options: FileManager.DirectoryEnumerationOptions
    ) throws -> [DirectoryEntry]

    /// Deletes all files that satisfy the provided predicate.
    ///
    /// - Parameter shouldDelete: A closure that returns `true` for files to delete.
    /// - Throws: An error if any delete operation fails.
    @discardableResult
    func deleteFiles(matching shouldDelete: (DirectoryEntry) -> Bool) throws -> Int

    /// Moves all files that satisfy the provided predicate into the specified destination folder.
    ///
    /// - Parameters:
    ///   - shouldMove: A closure that returns `true` for files to move.
    ///   - destination: The destination directory to move files into. The directory will be created if necessary.
    /// - Throws: An error if directory creation or any move operation fails.
    @discardableResult
    func moveFiles(matching shouldMove: (DirectoryEntry) -> Bool, to destination: some Directory) throws -> Int

    /// Copies all files in this folder to the specified destination folder.
    ///
    /// - Parameter destination: The destination directory to copy files into. The directory will be created if necessary.
    /// - Throws: An error if directory creation or any copy operation fails.
    @discardableResult
    func copyAllFiles(to destination: some Directory) throws -> Int
}

public extension FileSystemOperations {
    
    /// Indicates whether the folder exists on disk.
    var folderExists: Bool {
        folder.exists(using: agent)
    }
    
    /// Indicates whether the folder is empty (contains no files or directories).
    ///
    /// - Returns: `true` if the folder has no contents; otherwise, `false`.
    /// - Throws: An error if the directory does not exist, is not a directory, or cannot otherwise be accessed or enumerated (for example, due to permissions).
    func isEmpty() throws -> Bool {
        return try contents().isEmpty
    }
    
    /// Computes the total size, in bytes, of all regular files in the folder.
    ///
    /// - Returns: The sum of file sizes in bytes.
    /// - Throws: An error if the directory does not exist, is not a directory, or cannot otherwise be accessed or enumerated (for example, due to permissions).
    func totalSizeOfFiles() throws -> Int64 {
        let entries = try contents(includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey], options: [])
        return entries.reduce(into: Int64(0)) { sum, entry in
            guard entry.resourceValues.isRegularFile == true else { return }
            if let size = entry.resourceValues.fileSize {
                sum += Int64(size)
            }
        }
    }
}

public extension FileSystemOperations {
    
    /// Saves raw `Data` to disk.
    func saveData(_ data: Data, withName name: String) throws {
        try agent.createDirectoryIfNecessary(at: folder.location)
        let saver = SaveResource(agent: agent)
        try saver.saveData(data, withName: name, location: folder)
    }

    /// Loads raw `Data` from disk.
    func loadData(named name: String) throws -> Data {
        let loader = LoadResource(agent: agent)
        return try loader.loadData(named: name, location: folder)
    }
}

public extension FileSystemOperations {
    
    /// Saves an encodable resource to disk.
    func saveResource<Resource: Encodable>(_ resource: Resource, filename name: String) throws {
        try agent.createDirectoryIfNecessary(at: folder.location)
        let saver = SaveResource(agent: agent)
        try saver.saveResource(resource, withName: name, location: folder)
    }

    /// Loads a decodable resource from disk.
    func loadResource<Resource: Decodable>(filename: String) throws -> Resource {
        let loader = LoadResource(agent: agent)
        return try loader.loadResource(named: filename, location: folder)
    }

    /// Deletes a resource from disk.
    func deleteResource(filename: String) throws {
        let deleter = DeleteResource(agent: agent)
        try deleter.deleteResource(named: filename, location: folder)
    }

    /// Loads, modifies, and saves a codable resource back to disk.
    func updateResource<Resource: Codable>(filename name: String, modify: (inout Resource) -> Void) throws {
        let updater = UpdateResource(agent: agent)
        try updater.updateResource(named: name, location: folder, modify: modify)
    }
}

public extension FileSystemOperations {
    
    func deleteFiles(matching shouldDelete: (DirectoryEntry) -> Bool) throws -> Int {
        let op = DeleteFilesOperation(context: self)
        return try op.execute(matching: shouldDelete)
    }
    
    func moveFiles(matching shouldMove: (DirectoryEntry) -> Bool, to destination: some Directory) throws -> Int {
        let op = MoveFilesOperation(context: self)
        return try op.execute(matching: shouldMove, to: destination)
    }
    
    func copyAllFiles(to destination: some Directory) throws -> Int {
        let op = CopyAllResourcesOperation(context: self)
        return try op.execute(to: destination)
    }
}

public extension FileSystemOperations {

    /// Lists the contents of the store's folder and materializes requested resource values.
    ///
    /// - Parameters:
    ///   - keys: Resource keys to prefetch and materialize for each URL. Defaults to an empty list.
    ///   - options: Enumeration options that affect which items are returned and how. Defaults to an empty set.
    /// - Returns: An array of `DirectoryEntry` values for each item in the folder.
    /// - Throws: An error if the directory does not exist, is not a directory, or cannot otherwise be accessed or enumerated (for example, due to permissions).
    func contents(
        includingPropertiesForKeys keys: [URLResourceKey],
        options: FileManager.DirectoryEnumerationOptions
    ) throws -> [DirectoryEntry] {
        let urls = try agent.contentsOfDirectory(
            at: folder.location,
            includingPropertiesForKeys: keys,
            options: options
        )
        let keySet = Set(keys)
        return try urls.map { url in
            let values = try url.resourceValues(forKeys: keySet)
            return DirectoryEntry(url: url, resourceValues: values)
        }
    }
    
    /// Lists the contents of the store's folder and materializes requested resource values.
    ///
    /// - Returns: An array of `DirectoryEntry` values for each item in the folder.
    /// - Throws: An error if the directory does not exist, is not a directory, or cannot otherwise be accessed or enumerated (for example, due to permissions).
    func contents() throws -> [DirectoryEntry] {
        try contents(includingPropertiesForKeys: [], options: [])
    }
}
