//
//  SaveResource.swift
//  persistence
//
//  Created by Robert Nash on 07/02/2025.
//

import Foundation

/// A utility responsible for encoding and saving resources to the file system.
///
/// `SaveResource` supports saving both typed, encodable resources and raw `Data` to a given directory,
/// using a configurable `JSONEncoder` and a file system context.
struct SaveResource<Context: FileSystemContext> {
    
    /// The file system agent responsible for writing data to disk.
    private let agent: Context

    /// The encoder used to convert encodable values into `Data`.
    private let encoder: JSONEncoder

    /// Creates a new `SaveResource` instance.
    ///
    /// - Parameters:
    ///   - agent: The file system agent responsible for saving.
    ///   - encoder: A custom `JSONEncoder` used for encoding resources. Defaults to `.init()`.
    init(
        agent: Context,
        encoder: JSONEncoder = .init()
    ) {
        self.agent = agent
        self.encoder = encoder
    }

    /// Encodes and saves a resource to disk.
    ///
    /// - Parameters:
    ///   - resource: The encodable resource to save.
    ///   - name: The filename to write the resource to.
    ///   - folder: The folder in which to save the file.
    /// - Throws: A `SaveResourceError` if encoding or writing fails.
    func saveResource<
        Resource: Encodable,
        Folder: Directory
    >(
        _ resource: Resource,
        withName name: String,
        location folder: Folder
    ) throws(SaveResourceError) {
        let data = try createData(from: resource, key: name)
        try saveData(data, withName: name, location: folder)
    }

    /// Saves raw data to a file.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - name: The name of the file.
    ///   - folder: The folder in which to save the file.
    /// - Throws: A `SaveResourceError` if writing fails.
    func saveData<Folder: Directory>(
        _ data: Data,
        withName name: String,
        location folder: Folder
    ) throws(SaveResourceError) {
        do {
            try folder.createResource(filename: name, with: data, using: agent)
        } catch {
            throw SaveResourceError.fileSaveFailed(storageKey: name, underlyingError: error)
        }
    }

    /// Encodes a value into `Data` using the configured encoder.
    ///
    /// - Parameters:
    ///   - resource: The value to encode.
    ///   - key: The key used to identify the encoded file.
    /// - Returns: The encoded `Data` representation of the resource.
    /// - Throws: A `SaveResourceError.encodingFailed` if encoding fails.
    private func createData<R: Encodable>(from resource: R, key: String) throws(SaveResourceError) -> Data {
        do {
            return try encoder.encode(resource)
        } catch {
            throw SaveResourceError.encodingFailed(storageKey: key)
        }
    }
}

/// An error that occurs while attempting to save a resource to the file system.
enum SaveResourceError: Error {
    
    /// Indicates that the resource could not be encoded for storage.
    ///
    /// - Parameter storageKey: The key (or filename) used to store the resource.
    case encodingFailed(storageKey: String)
    
    /// Indicates that the file could not be written to disk.
    ///
    /// - Parameters:
    ///   - storageKey: The key (or filename) used to store the resource.
    ///   - underlyingError: The system error that caused the failure.
    case fileSaveFailed(storageKey: String, underlyingError: Error)
}

extension SaveResourceError: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .encodingFailed(let storageKey):
            return "Failed to encode resource with key '\(storageKey)'."
        case .fileSaveFailed(let storageKey, let error):
            return "Failed to save file with key '\(storageKey)': \(error.localizedDescription)."
        }
    }
}

extension SaveResourceError: LocalizedCustomerFacingError {
    
    var userFriendlyLocalizedDescription: String {
        switch self {
        case .encodingFailed:
            return String(
                localized: "save.file.error.encoding",
                defaultValue: "We couldn’t save your data. Please try again.",
                bundle: .module,
                comment: "Shown when encoding a resource fails. Avoids exposing internal keys or file names."
            )
            
        case .fileSaveFailed:
            return String(
                localized: "save.file.error.saving",
                defaultValue: "Saving the file didn’t work. Please try again.",
                bundle: .module,
                comment: "Shown when saving a file fails. General message, hides technical detail."
            )
        }
    }
}

extension SaveResourceError: Equatable {
    
    /// Compares two `SaveResourceError` values for equality.
    ///
    /// The comparison only considers the `storageKey` value and ignores the underlying error
    /// in the `.fileSaveFailed` case.
    ///
    /// - Parameters:
    ///   - lhs: The first error to compare.
    ///   - rhs: The second error to compare.
    /// - Returns: `true` if the errors are of the same case and have matching `storageKey` values; otherwise, `false`.
    public static func == (lhs: SaveResourceError, rhs: SaveResourceError) -> Bool {
        switch (lhs, rhs) {
        case let (.encodingFailed(lhsKey), .encodingFailed(rhsKey)):
            return lhsKey == rhsKey

        case let (.fileSaveFailed(lhsKey, _), .fileSaveFailed(rhsKey, _)):
            return lhsKey == rhsKey

        default:
            return false
        }
    }
}
