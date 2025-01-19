//
//  File.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation

/// A protocol representing a file resource with a name and a containing folder.
public protocol File: ~Copyable {
    
    associatedtype Folder: Directory
    
    /// The name of the file.
    var name: String { get }
    
    /// The enclosing folder containing the file.
    var enclosingFolder: Folder { get }
}

public extension File where Self: ~Copyable {
    
    /// The location of the file as a URL.
    var location: URL {
        enclosingFolder.location.appending(component: name, directoryHint: .notDirectory)
    }
    
    /// Determines whether the file exists in the file system context.
    ///
    /// - Parameter context: The file system context used to check for the file's existence.
    /// - Returns: A Boolean value indicating whether the file exists.
    func exists<Context: FileSystemContext>(using context: Context) -> Bool {
        context.locationExists(at: location)
    }
    
    /// Reads the contents of the file as data.
    ///
    /// - Returns: The data contained in the file.
    /// - Throws: An error if the file cannot be read.
    func read() throws -> Data {
        try Data(contentsOf: location)
    }
    
    /// Writes data to the file at its location.
    ///
    /// - Parameters:
    ///   - data: The data to write to the file.
    ///   - options: Options for writing the data. Default is an empty set.
    /// - Throws: An error if the data cannot be written to the file.
    func write(data: Data, options: NSData.WritingOptions = []) throws {
        try data.write(to: location, options: options)
    }
    
    /// Copies the file to a specified folder using the given file system context.
    ///
    /// - Parameters:
    ///   - folder: The destination folder where the file should be copied.
    ///   - context: The file system context used to perform the copy operation.
    /// - Throws: An error if the file cannot be copied.
    func copy<DestinationFolder: Directory, Context: FileSystemContext>(to folder: DestinationFolder, using context: Context) throws {
        let destination = folder.resourceLocation(for: self)
        try context.copyResource(from: location, to: destination)
    }
    
    /// Moves the file to a specified folder using the given file system context.
    ///
    /// - Parameters:
    ///   - folder: The destination folder where the file should be moved.
    ///   - context: The file system context used to perform the move operation.
    /// - Throws: An error if the file cannot be moved.
    consuming func move<DestinationFolder: Directory, Context: FileSystemContext>(to folder: DestinationFolder, using context: Context) throws {
        let destination = folder.resourceLocation(for: self)
        try context.moveResource(from: location, to: destination)
    }
    
    /// Deletes the file using the specified file system context.
    ///
    /// - Parameter context: The file system context used to delete the file.
    /// - Throws: An error if the file cannot be deleted.
    consuming func delete(using context: FileSystemContext) throws {
        try context.deleteLocation(at: location)
    }
}
