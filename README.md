# Files

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20visionOS%20%7C%20tvOS%20%7C%20watchOS-blue?logo=apple)

**Files** is a lightweight, protocol-oriented Swift library for working with file system resources. It supports modular, composable types for files and directories, and provides testable, injectable logic for reading, writing, and deleting data.

---

## Features

- Protocols for `File` and `Directory` modelling
- `FileSystemContext` abstraction for injecting logic or mocking
- `FileSystemFolderStore` for Codable storage and file management
- Log friendly and customer friendly Localized errors
- Built-in support for testability and mocking
- Strong preference for `~Copyable` to preserve resource identity

---

## Quick Start

### 1. Implement a `FileSystemContext`

```swift
struct LiveAgent: FileSystemContext {
    
    private let liveContext = FileManager.default

    func fileExists(at url: URL) -> Bool {
        liveContext.fileExists(atPath: url.path())
    }

    func folderExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = liveContext.fileExists(atPath: url.path(), isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    func url(for directory: FileSystemDirectory) throws -> URL {
        if let path = directory.searchPath {
            guard let resolved = liveContext.urls(for: path, in: .userDomainMask).first else {
                throw LiveAgentError.unableToResolveSearchPath(path)
            }
            return resolved
        }
        return liveContext.temporaryDirectory
    }

    func write(_ data: Data, to url: URL, options: NSData.WritingOptions) throws {
        try data.write(to: url, options: options)
    }

    func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
    
    // etc
}

enum LiveAgentError: Error {
    case unableToResolveSearchPath(FileManager.SearchPathDirectory)
}
```

---

### 2. Use `FileSystemFolderStore`

```swift
let folder = Folder(location: "./Whatever")
let agent = LiveAgent()
try agent.moveResource(from: xURL, to: yURL)
        
let store = FileSystemFolderStore(agent: agent, folder: folder, kind: .caches)

struct Greeting: Codable { let message: String }

try store.saveResource(Greeting(message: "Hello!"), filename: "greeting.json")

let greeting: Greeting = try store.loadResource(filename: "greeting.json")
```

---

### 3. Test With a Mock Context

```swift
let mock = MockContext(fileExistsHandler: { _ in true })
```

---

## Notes on `~Copyable`

While not enforced, `~Copyable` is strongly recommended for all `File` and `Directory` conformers:

- Prevents duplicate identity for the same file system location
- Ensures mutation methods like `move`, `delete` apply consistently
- Promotes safe and predictable resource handling

---

## Usage Philosophy

Use `FileSystemFolderStore` for most file-based logic.

You can also use `File`, `Directory`, and `Folder` types on their own for structural modelling.
