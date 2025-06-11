//
//  UpdateResource.swift
//  files
//
//  Created by Robert Nash on 07/02/2025.
//

import Foundation
import ErrorPresentation

/// A utility that facilitates loading, modifying, and saving a persisted resource.
///
/// `UpdateResource` is designed to work with different storage contexts, allowing
/// updates to stored resources in a structured and reusable way.
///
/// - Parameters:
///   - `Folder`: A type conforming to `Directory`, representing the storage folder.
///   - `Context`: A type conforming to `FileSystemContext`, representing the file system interaction layer.
struct UpdateResource<Context: FileSystemContext> {
    
    /// The file system context handling storage interactions.
    private let agent: Context
    
    /// Creates an `UpdateResource` instance.
    ///
    /// - Parameters:
    ///   - agent: The file system context handling storage interactions.
    init(agent: Context) {
        self.agent = agent
    }
    
    /// Loads a resource, applies modifications to it, and saves the updated resource.
    ///
    /// - Parameters:
    ///   - name: The name of the resource.
    ///   - location: The container folder for the resource.
    ///   - modify: A closure that receives an inout reference to the loaded resource, allowing it to be modified.
    /// - Throws: An error if loading or saving the resource fails.
    func updateResource<
        Resource: Codable,
        Folder: Directory
    >(
        named name: String,
        location folder: Folder,
        modify: (inout Resource) -> Void
    ) throws(UpdateResourceError) {
        let saver = SaveResource(agent: agent)
        let loader = LoadResource(agent: agent)
        do {
            var resource: Resource = try loader.loadResource(named: name, location: folder)
            modify(&resource)
            try saver.saveResource(resource, withName: name, location: folder)
        } catch let error as SaveResourceError {
            throw UpdateResourceError.saveError(underlyingError: error)
        } catch let error as LoadResourceError {
            throw UpdateResourceError.loadError(underlyingError: error)
        } catch {
            throw UpdateResourceError.unexpected(underlyingError: error)
        }
    }
}

/// An error that occurs while attempting to update a persisted resource.
enum UpdateResourceError: Error {
    
    /// Indicates a failure occurred while loading the resource.
    ///
    /// - Parameter underlyingError: The specific `LoadResourceError` that caused the failure.
    case loadError(underlyingError: LoadResourceError)
    
    /// Indicates a failure occurred while saving the resource after modification.
    ///
    /// - Parameter underlyingError: The specific `SaveResourceError` that caused the failure.
    case saveError(underlyingError: SaveResourceError)
    
    /// An unexpected error occurred during the update process.
    ///
    /// - Parameter underlyingError: The underlying error that was not anticipated.
    case unexpected(underlyingError: Error)
}

extension UpdateResourceError: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .loadError(let error):
            return "Update failed due to a load error: \(error.debugDescription)"
        case .saveError(let error):
            return "Update failed due to a save error: \(error.debugDescription)"
        case .unexpected(let error):
            return "Update failed with an unexpected error: \(error.localizedDescription)"
        }
    }
}

extension UpdateResourceError: LocalizedCustomerFacingError {
    
    var userFriendlyLocalizedDescription: String {
        switch self {
        case .loadError(let underlyingError):
            return underlyingError.userFriendlyLocalizedDescription
            
        case .saveError(let underlyingError):
            return underlyingError.userFriendlyLocalizedDescription
            
        case .unexpected:
            return String(
                localized: "update.resource.error.generic",
                defaultValue: "Something went wrong while updating your data. Please try again.",
                bundle: .module,
                comment: "Shown when an unexpected error occurs during a resource update."
            )
        }
    }
}

extension UpdateResourceError: Equatable {
    
    /// Compares two `UpdateResourceError` values for equality.
    ///
    /// - Note: For `.unexpected` cases, only the `localizedDescription` of the underlying error is compared.
    ///
    /// - Parameters:
    ///   - lhs: The first error to compare.
    ///   - rhs: The second error to compare.
    /// - Returns: `true` if both errors are of the same case and their relevant values match; otherwise, `false`.
    public static func == (lhs: UpdateResourceError, rhs: UpdateResourceError) -> Bool {
        switch (lhs, rhs) {
        case let (.loadError(lhsErr), .loadError(rhsErr)):
            return lhsErr == rhsErr

        case let (.saveError(lhsErr), .saveError(rhsErr)):
            return lhsErr == rhsErr

        case let (.unexpected(lhsErr), .unexpected(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription

        default:
            return false
        }
    }
}
