//
//  URLExpectation.swift
//  files
//
//  Created by Robert Nash on 08/06/2025.
//

import Foundation
import Testing

/// A test helper for asserting that expected URLs are used in file system operations.
struct URLExpectation {
    
    /// Asserts that the actual URL passed into a test handler matches an expected URL exactly.
    ///
    /// Use this helper when the test should confirm that a file operation targets an exact file path,
    /// including filename and directory structure.
    ///
    /// - Parameters:
    ///   - expected: The URL you expect to be passed in.
    ///   - message: An optional comment to describe the assertion in test output.
    /// - Returns: A closure that always returns `true`, but triggers an expectation if the URLs do not match.
    static func exact(_ expected: URL, message: Comment?) -> (URL) -> Bool {
        return { actual in
            #expect(actual == expected, message)
            return true
        }
    }
    
    /// Asserts that the actual URL passed into a test handler is located inside the specified folder.
    ///
    /// This is useful when validating that file operations (e.g. `save`, `copy`, `delete`) are scoped within
    /// a particular root directory, but do not need to match an exact file path.
    ///
    /// - Parameters:
    ///   - folder: The expected parent directory for the URL being passed in.
    ///   - message: An optional comment to describe the assertion in test output.
    /// - Returns: A closure that always returns `true`, but triggers an expectation if the URL is outside the folder.
    static func insideFolder(_ folder: URL, message: Comment?) -> (URL) -> Bool {
        return { actual in
            #expect(actual.path.hasPrefix(folder.path), message)
            return true
        }
    }
    
    /// Creates a throwing handler that asserts the URL matches the expected value.
    ///
    /// This is typically used in mock handler injections where a failure (e.g., delete or create)
    /// is expected to be simulated during tests. The closure returns `Void` and throws the supplied error
    /// after verifying the correct URL was passed to the mock.
    ///
    /// - Parameters:
    ///   - expected: The URL you expect the handler to be called with.
    ///   - message: A comment for failure output if the actual URL doesn't match.
    ///   - error: The error to be thrown if the assertion passes.
    /// - Returns: A `(URL) throws -> Void` closure for use in mock handler setup.
    static func throwing(_ expected: URL, message: Comment?, error: Error) -> (URL) throws -> Void {
        return { actual in
            #expect(actual == expected, message)
            throw error
        }
    }
    
    /// Creates a throwing data handler that asserts the URL matches the expected value and simulates a read failure.
    ///
    /// This variant is specifically for `readHandler`, where the signature requires a
    /// return type of `Data`. It asserts that the URL being read is correct, then throws the given error.
    ///
    /// - Parameters:
    ///   - expected: The expected URL to be passed to the read handler.
    ///   - message: A comment for assertion failure diagnostics.
    ///   - error: The error to be thrown after assertion.
    /// - Returns: A `(URL) throws -> Data` closure that always throws the provided error.
    static func throwingData(_ expected: URL, message: Comment?, error: Error) -> (URL) throws -> Data {
        return { actual in
            #expect(actual == expected, message)
            throw error
        }
    }
    
    /// Simulates a non-throwing no-op file operation (e.g. `delete`, `create`) while asserting the input URL.
    ///
    /// This is useful in tests where you want to confirm that a handler was invoked with the expected location,
    /// but you don’t need the handler to perform any action or throw.
    ///
    /// - Parameters:
    ///   - expected: The expected URL passed into the handler.
    ///   - message: An optional comment to describe the assertion in test output.
    /// - Returns: A closure that does nothing if the URL matches, but triggers an expectation failure otherwise.
    static func asserting(_ expected: URL, message: Comment?) -> (URL) throws -> Void {
        return { actual in
            #expect(actual == expected, message)
        }
    }

    /// Simulates a move or copy operation between two URLs while asserting both the source and destination.
    ///
    /// This is useful in test contexts where the exact source and destination URLs used in file operations
    /// (e.g., `copyResource(from:to:)`, `moveResource(from:to:)`) must be verified to ensure correctness.
    ///
    /// - Parameters:
    ///   - expectedFrom: The expected origin URL from which the resource is moved or copied.
    ///   - expectedTo: The expected destination URL to which the resource is moved or copied.
    ///   - message: A description used to prefix failure messages for improved test failure clarity.
    /// - Returns: A closure that does not perform an actual operation, but asserts that both arguments match expectations.
    static func moveOrCopy(
        expectedFrom: URL,
        expectedTo: URL,
        message: String
    ) -> (URL, URL) throws -> Void {
        return { from, to in
            #expect(from == expectedFrom, "\(message): Unexpected source URL.")
            #expect(to == expectedTo, "\(message): Unexpected destination URL.")
        }
    }

    /// Simulates a data-loading operation from disk, returning predefined `Data` and asserting the input URL.
    ///
    /// This is useful for mocking successful file reads in tests that involve decoding resources
    /// using `loadResource(filename:)`, while ensuring the read operation targets the correct file.
    ///
    /// - Parameters:
    ///   - expected: The expected URL of the file to read.
    ///   - data: The data to return as the simulated file contents.
    ///   - message: An optional comment to attach to the expectation if the URL check fails.
    /// - Returns: A closure that returns `data` when invoked with the correct `URL`, otherwise fails the test.
    static func returningData(
        _ expected: URL,
        data: Data,
        message: Comment?
    ) -> (URL) throws -> Data {
        return { actual in
            #expect(actual == expected, message)
            return data
        }
    }
}
