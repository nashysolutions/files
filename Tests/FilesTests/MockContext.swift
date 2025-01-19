//
//  MockContext.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Testing
import Files

final class MockContext: FileSystemContext {
    
    enum Endpoint {
        case locationExists
        case moveResource
        case copyResource
        case deleteLocation
        case createDirectory
    }
    
    var called: [Endpoint] = []
    
    var locationExistsHandler: ((URL) -> Bool)?
    var moveResourceHandler: ((URL, URL) throws -> Void)?
    var copyResourceHandler: ((URL, URL) throws -> Void)?
    var deleteLocationHandler: ((URL) throws -> Void)?
    var createDirectoryHandler: ((URL) throws -> Void)?
    
    init(
        locationExistsHandler: ((URL) -> Bool)? = nil,
        moveResourceHandler: ((URL, URL) throws -> Void)? = nil,
        copyResourceHandler: ((URL, URL) throws -> Void)? = nil,
        deleteLocationHandler: ((URL) throws -> Void)? = nil,
        createDirectoryHandler: ((URL) throws -> Void)? = nil
    ) {
        self.locationExistsHandler = locationExistsHandler
        self.moveResourceHandler = moveResourceHandler
        self.copyResourceHandler = copyResourceHandler
        self.deleteLocationHandler = deleteLocationHandler
        self.createDirectoryHandler = createDirectoryHandler
    }
    
    func locationExists(at url: URL) -> Bool {
        called.append(.locationExists)
        return locationExistsHandler?(url) ?? true
    }
    
    func moveResource(from fromURL: URL, to toURL: URL) throws {
        called.append(.moveResource)
        try moveResourceHandler?(fromURL, toURL) ?? {
            Issue.record("Default move behaviour invoked.")
        }()
    }
    
    func copyResource(from fromURL: URL, to toURL: URL) throws {
        called.append(.copyResource)
        try copyResourceHandler?(fromURL, toURL) ?? {
            Issue.record("Default copy behaviour invoked.")
        }()
    }
    
    func deleteLocation(at url: URL) throws {
        called.append(.deleteLocation)
        try deleteLocationHandler?(url) ?? {
            Issue.record("Default delete behaviour invoked.")
        }()
    }
    
    func createDirectory(at url: URL) throws {
        called.append(.createDirectory)
        try createDirectoryHandler?(url) ?? {
            Issue.record("Default create directory behaviour invoked.")
        }()
    }
}
