//
//  Directory.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

/// A protocol representing a directory in the file system.
public protocol Directory {
    
    /// The location of this directory.
    var location: URL { get }
    
    /// Determines whether this directory exists.
    /// - Parameter context: The `FileSystemContext` used for file system operations.
    /// - Returns: `true` if a folder is found at the URL, otherwise `false`.
    func exists(using context: FileSystemContext) -> Bool
    
    /// Lists the contents of this directory and returns entries with optional resource attributes.
    ///
    /// This method delegates enumeration to the provided `FileSystemContext`, then materialises
    /// `URLResourceValues` for each returned URL using the keys you specify. The resulting
    /// `DirectoryEntry` objects bundle the URL and its resource values for ergonomic access.
    ///
    /// - Parameters:
    ///   - context: The file system context used to perform the enumeration.
    ///   - keys: Resource keys to prefetch and materialize for each URL. Defaults to an empty list.
    ///   - options: Enumeration options that affect which items are returned and how. Defaults to an empty set.
    /// - Returns: An array of ``DirectoryEntry`` values, one for each item in the directory.
    /// - Throws: An error if the directory cannot be accessed or enumerated.
    ///
    /// - Note: If `keys` is empty, `resourceValues` in each entry will contain no populated properties
    ///   (properties will be `nil`), unless values are otherwise cached by the system.
    ///
    /// - SeeAlso: ``DirectoryEntry``
    /// - SeeAlso: ``DirectoryEntry/value(_:)``
    func contents(
        using context: FileSystemContext,
        includingPropertiesForKeys keys: [URLResourceKey],
        options: FileManager.DirectoryEnumerationOptions
    ) throws -> [DirectoryEntry]
    
    /// Ensures this directory (folder) exists at the specified URL, creating it if necessary.
    /// - Parameter context: The `FileSystemContext` used for file system operations.
    /// - Throws: An error if the operation to create the folder fails.
    func createIfNecessary(using context: FileSystemContext) throws
    
    /// Deletes this directory if it exists at the specified location.
    ///
    /// This method attempts to remove the directory at the `location` URL.
    /// If the directory does not exist, the method does nothing.
    ///
    /// - Parameter context: The `FileSystemContext` used for file system operations.
    /// - Throws: An error if the operation to delete the directory fails.
    func deleteIfExists(using context: FileSystemContext) throws
    
    /// Creates a resource (file) in the directory with the given name and data.
    ///
    /// This method ensures that the directory exists before creating the resource. If the directory
    /// does not exist, it will be created. The provided data will then be written to the specified resource.
    ///
    /// - Parameters:
    ///   - name: The name of the resource to create.
    ///   - data: The data to write to the resource.
    ///   - context: The `FileSystemContext` used for file system operations.
    /// - Throws: An error if creating the directory or writing the resource fails.
    func createResource(
        filename name: String,
        with data: Data,
        using context: FileSystemContext
    ) throws
    
    /// Retrieves the expected location for a resource within the directory.
    ///
    /// - Parameter resource: The resource whose location is being determined.
    /// - Returns: A URL representing the location of the resource within the directory.
    func resourceLocation<Resource>(
        for resource: borrowing Resource
    ) -> URL where Resource: StoredItem & ~Copyable
}

public extension Directory {
    
    func exists(using context: FileSystemContext) -> Bool {
        context.folderExists(at: location)
    }
    
    func contents(
        using context: FileSystemContext,
        includingPropertiesForKeys keys: [URLResourceKey] = [],
        options: FileManager.DirectoryEnumerationOptions = []
    ) throws -> [DirectoryEntry] {
        
        let urls = try context.contentsOfDirectory(
            at: location,
            includingPropertiesForKeys: keys,
            options: options
        )
        
        let keySet = Set(keys)
        return try urls.map { url in
            let values = try url.resourceValues(forKeys: keySet)
            return DirectoryEntry(url: url, resourceValues: values)
        }
    }
    
    func createIfNecessary(
        using context: FileSystemContext
    ) throws {
        try context
            .createDirectoryIfNecessary(
                at: location
            )
    }
    
    func deleteIfExists(
        using context: FileSystemContext
    ) throws {
        try context
            .deleteDirectoryIfExists(
                at: location
            )
    }
    
    func resource(
        filename: String
    ) -> some StoredItem & ~Copyable {
        Resource(filename: filename, enclosingFolder: self)
    }
    
    func createResource(
        filename name: String,
        with data: Data,
        using context: FileSystemContext
    ) throws {
        try createIfNecessary(using: context)
        let resource = Resource(filename: name, enclosingFolder: self)
        try resource.write(data: data, using: context)
    }
    
    func resourceLocation<Resource>(
        for resource: borrowing Resource
    ) -> URL where Resource: StoredItem & ~Copyable {
        location
            .appending(
                component: resource.filename,
                directoryHint: .notDirectory
            )
    }
}

private struct Resource<Folder: Directory>: ~Copyable, StoredItem {
    let filename: String
    let enclosingFolder: Folder
}
