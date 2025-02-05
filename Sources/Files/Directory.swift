//
//  Directory.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

/// A protocol representing a directory in the file system.
public protocol Directory {
    var location: URL { get }
}

public extension Directory {
    
    /// Ensures this directory (folder) exists at the specified URL, creating it if necessary.
    /// - Parameter url: The location of the folder to check or create.
    /// - Throws: An error if the operation to create the folder fails.
    func createDirectoryIfNecessary(
        using context: FileSystemContext
    ) throws {
        try context
            .createDirectoryIfNecessary(
                at: location
            )
    }
    
    /// Deletes this directory if it exists at the specified location.
    ///
    /// This method attempts to remove the directory at the `location` URL.
    /// If the directory does not exist, the method does nothing.
    ///
    /// - Parameter context: The `FileSystemContext` used for file system operations.
    /// - Throws: An error if the operation to delete the directory fails.
    func deleteDirectoryIfExists(
        using context: FileSystemContext
    ) throws {
        try context
            .deleteDirectoryIfExists(
                at: location
            )
    }
    
    /// Retrieves a resource (file) within this directory by name.
    ///
    /// This method creates an instance representing a file with the given name inside the current directory.
    /// The returned resource conforms to `File` and is non-copyable (`~Copyable`).
    ///
    /// - Parameter name: The name of the resource (file) to retrieve.
    /// - Returns: A `File` instance representing the requested resource.
    /// - Note: The returned resource is non-copyable, meaning it cannot be duplicated or reassigned after consumption.
    /// - SeeAlso: ``createResource(named:with:using:)``
    func resource(named name: String) -> some File & ~Copyable {
        Resource(name: name, enclosingFolder: self)
    }
    
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
        named name: String,
        with data: Data,
        using context: FileSystemContext
    ) throws {
        try createDirectoryIfNecessary(using: context)
        let resource = Resource(name: name, enclosingFolder: self)
        try resource.write(data: data)
    }
    
    /// Retrieves the expected location for a resource within the directory.
    ///
    /// - Parameter resource: The resource whose location is being determined.
    /// - Returns: A URL representing the location of the resource within the directory.
    func resourceLocation<Resource>(
        for resource: borrowing Resource
    ) -> URL where Resource: File & ~Copyable {
        location
            .appending(
                component: resource.name,
                directoryHint: .notDirectory
            )
    }
}

private struct Resource<Folder: Directory>: ~Copyable, File {
    let name: String
    let enclosingFolder: Folder
}
