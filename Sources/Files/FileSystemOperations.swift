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
    func saveResource<Resource: Encodable>(_ resource: Resource, filename name: String) throws

    /// Loads a decodable resource from disk.
    ///
    /// - Parameter filename: The name of the file to load.
    /// - Returns: The decoded resource.
    func loadResource<Resource: Decodable>(filename: String) throws -> Resource

    /// Deletes a resource from disk.
    ///
    /// - Parameter filename: The name of the file to delete.
    func deleteResource(filename: String) throws

    /// Loads, modifies, and re-saves a codable resource.
    ///
    /// - Parameters:
    ///   - name: The name of the file to update.
    ///   - modify: A closure that receives an `inout` reference to the resource for modification.
    func updateResource<Resource: Codable>(filename name: String, modify: (inout Resource) -> Void) throws

    /// Saves raw `Data` to disk.
    ///
    /// - Parameters:
    ///   - data: The data to save.
    ///   - name: The name of the file to save to.
    func saveData(_ data: Data, withName name: String) throws

    /// Loads raw `Data` from disk.
    ///
    /// - Parameter name: The name of the file to load.
    /// - Returns: The loaded data.
    func loadData(named name: String) throws -> Data
}

public extension FileSystemOperations {
    
    /// Indicates whether the folder exists on disk.
    var folderExists: Bool {
        folder.exists(using: agent)
    }

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

    /// Loads a file from the folder by name.
    ///
    /// - Parameter filename: The name of the file.
    /// - Returns: A file instance conforming to `File` and `~Copyable`.
    func loadFile(filename: String) -> some File & ~Copyable {
        folder.resource(filename: filename)
    }
}
