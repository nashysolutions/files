//
//  LocalizedCustomerFacingError.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation

/// A protocol for errors that present a clean, user-friendly message suitable for UI display.
///
/// This protocol refines `LocalizedError` by introducing a single, clear entry point for
/// localised messaging: `userFriendlyLocalizedDescription`. It is intended for use in user-facing
/// alerts, messages, and interfaces where technical detail is inappropriate or confusing.
///
/// The goal is to **avoid leaking internal implementation details** (such as field or enum case names),
/// and instead focus on how the error *feels* or *impacts* the user.
///
/// ### Why not use `Error.localizedDescription` directly?
/// Swift errors are automatically bridged to `NSError` from Objective-C, which gives all errors a
/// default `localizedDescription` property. However, this often results in vague, overly technical,
/// or framework-generated messages like:
///
///     "The operation couldn’t be completed. (MyApp.MyError error 1.)"
///
/// To avoid these pitfalls, this protocol **intentionally bypasses the `NSError`-style fallback** by
/// requiring a `userFriendlyLocalizedDescription`, and routing `errorDescription` through it.
/// This keeps your error messages clean, predictable, and appropriate for users.
///
/// ### Best Practices
/// - Avoid exposing internal field names or type names.
/// - Focus on what the user can understand or act on.
/// - Keep messages localised, brief, and actionable.
///
/// Adopt this protocol in any custom error that may be presented to the user in a UI context.
public protocol LocalizedCustomerFacingError: LocalizedError {
    /// A simplified, localised error description suitable for end users.
    var userFriendlyLocalizedDescription: String { get }
}

public extension LocalizedCustomerFacingError {
    /// Provides the user-facing description as the standard `LocalizedError.errorDescription`,
    /// allowing integration with SwiftUI alerts and other system APIs without falling back to `NSError` behaviour.
    var errorDescription: String? {
        userFriendlyLocalizedDescription
    }
}
