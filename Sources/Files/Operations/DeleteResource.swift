//
//  DeleteResource.swift
//  files
//
//  Created by Robert Nash on 06/02/2025.
//

import Foundation

/// A utility responsible for deleting a persisted file-based resource.
///
/// `DeleteResource` abstracts the deletion of files within a specified folder using a provided file system context.
struct DeleteResource<Context: FileSystemContext> {
    
    /// The file system context responsible for performing deletion.
    private let agent: Context

    /// Creates a new `DeleteResource` instance.
    ///
    /// - Parameter agent: The file system agent used to perform deletion.
    init(agent: Context) {
        self.agent = agent
    }

    /// Deletes a file from the given folder.
    ///
    /// - Parameters:
    ///   - name: The name (or key) of the file to delete.
    ///   - folder: The directory in which the file is located.
    /// - Throws: A `DeleteResourceError` if the file could not be deleted.
    func deleteResource<Folder: Directory>(
        named name: String,
        location folder: Folder
    ) throws(DeleteResourceError) {
        let resource = folder.resource(filename: name)
        do {
            try resource.delete(using: agent)
        } catch {
            throw DeleteResourceError.fileDeleteFailed(storageKey: name, underlyingError: error)
        }
    }
}

/// An error that occurs during deletion of a file-based resource.
enum DeleteResourceError: Error {
    
    /// Indicates the file could not be deleted.
    ///
    /// - Parameters:
    ///   - storageKey: The key or filename used to identify the file.
    ///   - underlyingError: The system-level error that occurred during deletion.
    case fileDeleteFailed(storageKey: String, underlyingError: Error)
}

extension DeleteResourceError: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .fileDeleteFailed(let key, let error):
            "Failed to delete the file named '\(key)': \(error.localizedDescription)"
        }
    }
}

extension DeleteResourceError: LocalizedError {
    
    /// A simplified, user-friendly message suitable for display in alerts or UI.
    public var errorDescription: String? {
        switch self {
        case .fileDeleteFailed:
            return String(
                localized: "delete.file.error.generic",
                defaultValue: "Something went wrong while removing a file. Please try again.",
                bundle: .module,
                comment: "Generic user-facing error when file deletion fails. No technical detail included."
            )
        }
    }
}

/// Conformance to `Equatable` for comparing deletion errors.
///
/// This implementation compares only the `storageKey` of the file that failed to delete.
/// The `underlyingError` is not considered in the comparison, as it is typically
/// system-generated and not `Equatable`.
extension DeleteResourceError: Equatable {
    
    /// Returns a Boolean value indicating whether two `DeleteResourceError` values are equal.
    ///
    /// Only the `storageKey` is compared. The `underlyingError` is ignored for
    /// the purposes of equality to allow predictable comparisons in testing and logic.
    ///
    /// - Parameters:
    ///   - lhs: A `DeleteResourceError` value.
    ///   - rhs: Another `DeleteResourceError` value to compare against.
    /// - Returns: `true` if both errors are of the same case and have equal `storageKey` values; otherwise, `false`.
    public static func == (lhs: DeleteResourceError, rhs: DeleteResourceError) -> Bool {
        switch (lhs, rhs) {
        case let (.fileDeleteFailed(lKey, _), .fileDeleteFailed(rKey, _)):
            return lKey == rKey
        }
    }
}
