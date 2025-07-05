//
//  LoadResource.swift
//  files
//
//  Created by Robert Nash on 07/02/2025.
//

import Foundation

/// A utility that facilitates loading data and decoding resources from the file system.
///
/// `LoadResource` provides functionality to read raw `Data` or decode a typed resource from a given folder
/// using a provided `FileSystemContext`. It supports custom decoding strategies via `JSONDecoder`.
struct LoadResource<Context: FileSystemContext> {
    
    /// The file system context used to access file content.
    private let agent: Context

    /// The decoder used to convert data into typed resources.
    private let decoder: JSONDecoder

    /// Creates a new `LoadResource` instance.
    ///
    /// - Parameters:
    ///   - agent: The file system agent responsible for file reading.
    ///   - decoder: A custom `JSONDecoder` for decoding resource data. Defaults to `.init()`.
    init(
        agent: Context,
        decoder: JSONDecoder = .init()
    ) {
        self.agent = agent
        self.decoder = decoder
    }

    /// Loads and decodes a typed resource from a file.
    ///
    /// - Parameters:
    ///   - name: The name (or key) of the file.
    ///   - folder: The directory containing the file.
    /// - Returns: The decoded resource of type `Resource`.
    /// - Throws: A `LoadResourceError` if reading or decoding the resource fails.
    func loadResource<
        Resource: Decodable,
        Folder: Directory
    >(
        named name: String,
        location folder: Folder
    ) throws(LoadResourceError) -> Resource {
        
        let data = try loadData(named: name, location: folder)

        do {
            return try decoder.decode(Resource.self, from: data)
        } catch {
            throw LoadResourceError.decodingFailed(storageKey: name)
        }
    }

    /// Loads raw data from a file in the specified folder.
    ///
    /// - Parameters:
    ///   - name: The name (or key) of the file.
    ///   - folder: The directory containing the file.
    /// - Returns: The file's contents as `Data`.
    /// - Throws: A `LoadResourceError` if the file is empty, unreadable, or missing.
    func loadData<Folder: Directory>(
        named name: String,
        location folder: Folder
    ) throws(LoadResourceError) -> Data {
                
        let resource = folder.resource(filename: name)

        let data: Data
        do {
            data = try resource.read(using: agent)
        } catch {
            throw LoadResourceError.fileReadFailed(storageKey: name, underlyingError: error)
        }

        guard !data.isEmpty else {
            throw LoadResourceError.emptyFile(storageKey: name)
        }

        return data
    }
}

/// An error that occurs while attempting to load a resource from the file system.
enum LoadResourceError: Error {
    
    /// Indicates that the file exists but is empty.
    ///
    /// - Parameter storageKey: The key (or filename) used to identify the file.
    case emptyFile(storageKey: String)
    
    /// Indicates that the file could not be decoded into the expected type.
    ///
    /// - Parameter storageKey: The key (or filename) used to identify the file.
    case decodingFailed(storageKey: String)
    
    /// Indicates that the file could not be read from disk.
    ///
    /// - Parameters:
    ///   - storageKey: The key (or filename) used to identify the file.
    ///   - underlyingError: The system error that caused the read failure.
    case fileReadFailed(storageKey: String, underlyingError: Error)
}

extension LoadResourceError: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .emptyFile(let storageKey):
            return "The file with key '\(storageKey)' is empty."
        case .decodingFailed(let storageKey):
            return "Failed to decode the contents of the file with key '\(storageKey)'."
        case .fileReadFailed(let storageKey, let error):
            return "Failed to read the file with key '\(storageKey)': \(error.localizedDescription)"
        }
    }
}

extension LoadResourceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .emptyFile(let storageKey):
            return String(
                localized: "load.file.error.empty",
                defaultValue: "The file \(storageKey) is empty.",
                bundle: .module,
                comment: "Shown when a file exists but contains no data."
            )
            
        case .decodingFailed(let storageKey):
            return String(
                localized: "load.file.error.decoding",
                defaultValue: "Failed to decode the contents of the file \(storageKey).",
                bundle: .module,
                comment: "Shown when decoding a file into a resource fails."
            )
            
        case .fileReadFailed(let storageKey, let error):
            return String(
                localized: "load.file.error.reading",
                defaultValue: "Failed to read the file \(storageKey): \(error.localizedDescription).",
                bundle: .module,
                comment: "Shown when a file cannot be read. First is the file name, second is the system error."
            )
        }
    }
}

extension LoadResourceError: Equatable {
    
    /// Compares two `LoadResourceError` values for equality.
    ///
    /// The comparison checks that the errors are of the same case and that their associated
    /// `storageKey` values match. The `underlyingError` is not considered in `.fileReadFailed`.
    ///
    /// - Parameters:
    ///   - lhs: The first error to compare.
    ///   - rhs: The second error to compare.
    /// - Returns: `true` if the cases match and associated values are equal; otherwise, `false`.
    public static func == (lhs: LoadResourceError, rhs: LoadResourceError) -> Bool {
        switch (lhs, rhs) {
        case let (.emptyFile(lhsKey), .emptyFile(rhsKey)):
            return lhsKey == rhsKey

        case let (.decodingFailed(lhsKey), .decodingFailed(rhsKey)):
            return lhsKey == rhsKey

        case let (.fileReadFailed(lhsKey, _), .fileReadFailed(rhsKey, _)):
            return lhsKey == rhsKey

        default:
            return false
        }
    }
}
