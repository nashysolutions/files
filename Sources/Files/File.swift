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
    var filename: String { get }
    
    /// The enclosing folder containing the file.
    var enclosingFolder: Folder { get }
}

public extension File where Self: ~Copyable {
    
    /// The location of the file as a URL.
    var location: URL {
        enclosingFolder.location.appending(component: filename, directoryHint: .notDirectory)
    }
    
    /// Determines whether the file exists in the file system context.
    func exists<Context: FileSystemContext>(using context: Context) -> Bool {
        context.fileExists(at: location)
    }

    /// Reads the contents of the file as data via the provided file system context.
    func read<Context: FileSystemContext>(using context: Context) throws -> Data {
        try context.read(from: location)
    }

    /// Writes data to the file via the provided file system context.
    func write<Context: FileSystemContext>(data: Data, using context: Context, options: NSData.WritingOptions = []) throws {
        try context.write(data, to: location, options: options)
    }

    /// Copies the file to a specified folder using the given file system context.
    func copy<DestinationFolder: Directory, Context: FileSystemContext>(to folder: DestinationFolder, using context: Context) throws {
        let destination = folder.resourceLocation(for: self)
        try context.copyResource(from: location, to: destination)
    }

    /// Moves the file to a specified folder using the given file system context.
    consuming func move<DestinationFolder: Directory, Context: FileSystemContext>(to folder: DestinationFolder, using context: Context) throws {
        let destination = folder.resourceLocation(for: self)
        try context.moveResource(from: location, to: destination)
    }

    /// Deletes the file using the specified file system context.
    consuming func delete(using context: FileSystemContext) throws {
        try context.deleteLocation(at: location)
    }
}
