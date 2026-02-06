//
//  DirectoryEntry.swift
//  files
//
//  Created by Robert Nash on 05/02/2026.
//

import Foundation

/// A lightweight value that represents an item found during directory enumeration.
///
/// `DirectoryEntry` bundles the item's `url` together with pre-fetched `URLResourceValues`.
/// The values correspond to the keys requested via `includingPropertiesForKeys` when calling
/// `Directory.contents(...)`. Individual properties inside `URLResourceValues` are optional and
/// will be `nil` if the corresponding key wasn't requested or the value isn't available.
///
/// Notes:
/// - `resourceValues` is intentionally non-optional for ergonomics; absence is represented by
///   `nil` properties within `URLResourceValues`.
/// - The type is `Sendable` to allow safe use across concurrency domains.
public struct DirectoryEntry {
    /// The file-system URL of the item.
    public let url: URL
    /// Resource values fetched for this item. Properties are optional and may be `nil` if not requested or unavailable.`
    ///
    /// - SeeAlso: ``DirectoryEntry/value(_:)``
    public let resourceValues: URLResourceValues
}

public extension DirectoryEntry {
    
    init(url: URL, keys: Set<URLResourceKey>) throws {
        self.url = url
        self.resourceValues = try url.resourceValues(forKeys: keys)
    }
}

public extension DirectoryEntry {
    /// Convenience accessor for values inside `URLResourceValues` using a key path.
    ///
    /// This helper keeps call sites succinct, e.g. `entry.value(\.isDirectory)`.
    /// Remember that properties inside `URLResourceValues` are optional; this method
    /// returns `nil` if the value wasn't requested or isn't available.
    /// - Parameter keyPath: Key path to a specific optional value in `URLResourceValues`.
    /// - Returns: The value if available, otherwise `nil`.
    func value<T>(_ keyPath: KeyPath<URLResourceValues, T?>) -> T? {
        resourceValues[keyPath: keyPath]
    }
}
