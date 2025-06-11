//
//  DeleteResourceErrorTests.swift
//  files
//
//  Created by Robert Nash on 10/06/2025.
//

import Foundation
import Testing

@testable import Files

@Suite
struct DeleteResourceErrorTests {
    
    @Test("returns user-facing description")
    func userFacingDescriptionIsLocalisedOrFallback() {
        let error = DeleteResourceError.fileDeleteFailed(
            storageKey: "example.json",
            underlyingError: CocoaError(.fileNoSuchFile)
        )
        
        #expect(
            error.userFriendlyLocalizedDescription == "Something went wrong while removing a file. Please try again."
        )
    }
    
    @Test("returns developer-facing debug description")
    func debugDescriptionIncludesFilenameAndError() {
        let error = DeleteResourceError.fileDeleteFailed(
            storageKey: "example.json",
            underlyingError: CocoaError(.fileNoSuchFile)
        )
        
        #expect(error.debugDescription == "Failed to delete the file named 'example.json': The file doesn’t exist.")
    }
}
