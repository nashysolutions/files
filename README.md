# Files
  
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift) ![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20visionOS%20%7C%20tvOS%20%7C%20watchOS-blue?logo=apple)

A lightweight Swift library for managing file system resources in a protocol-oriented manner.

## Features

- Defines protocols for file system entities: `File` and `Directory`
- Provides convenience methods for reading, writing, copying, and deleting files
- Supports a `FileSystemContext` abstraction for file operations
- Encourages non-copyable (`~Copyable`) implementations to maintain resource integrity

## Installation

You can add this library to your Swift project using **Swift Package Manager**.

### Swift Package Manager

1. Open your Xcode project.
2. Go to **File** → **Add Packages**.
3. Enter the repository URL:

```
https://github.com/nashysolutions/files.git
```

## Getting Started

Creating Concrete Types

To work with files and directories, define your own concrete types conforming to File and Directory.

⚠️ **Important:** While `File` does not enforce `~Copyable`, it is strongly recommended to adopt `~Copyable` to avoid unintended duplication of resources.

```swift
struct Folder: Directory {
    let location: URL
}

struct Resource: File, ~Copyable {
    let name: String
    let enclosingFolder: Folder
}
```

## Basic Usage

Create a context that conforms to `FileSystemContext` for handling file system tasks:

```swift
struct Agent: FileSystemContext {
    
    let manager: FileManager
    
    init(manager: FileManager) {
        self.manager = manager
    }
    
    // implement required functions here
}
```

### Creating a Directory

```swift
let location: URL = /* some directory */
let folder = Folder(location: location)
try folder.createDirectoryIfNecessary(using: agent)
```

### Creating a File

```swift
let location: URL = /* some directory */
let folder = Folder(location: location)
let resource: some File & ~Copyable = folder.resource(named: "dogs.json")
```

### Writing a File

```swift
let file = Resource(name: "example.txt", enclosingFolder: folder)
let data = Data("Hello, world!".utf8)
try file.write(data: data)
```

### Checking File Existinece

```swift
let exists = file.exists(using: context)
print("File exists: \(exists)")
```

etc

### Wrappers

You could build a wrapper like this for example

```swift
public struct SaveResource<Folder: Directory, Context: FileSystemContext> {
    
    private let agent: Context
    private let folder: Folder
    private let encoder: JSONEncoder
    
    public init(
        agent: Context,
        folder: Folder,
        encoder: JSONEncoder = .init()
    ) {
        self.agent = agent
        self.folder = folder
        self.encoder = encoder
    }
    
    public func save<R: Encodable>(resource: R, withName name: String) throws {
        let data = try createData(from: resource, key: name)
        try save(data: data, withName: name)
    }
    
    public func save(data: Data, withName name: String) throws {
        do {
            try folder.createResource(named: name, with: data, using: agent)
        } catch {
            throw SaveError.fileSaveFailed(storageKey: name, underlyingError: error)
        }
    }
    
    private func createData<R: Encodable>(from resource: R, key: String) throws -> Data {
        do {
            return try encoder.encode(resource)
        } catch {
            throw SaveError.encodingFailed(storageKey: key)
        }
    }
}
```

and use it like this

```swift
private let fileManager = FileManager.default

private func documentsDirectory() throws -> URL {
    try fileManager.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    )
}

private func makeFolder() throws -> Folder {
    let location = try documentsDirectory()
    return Folder(location: location)
}

private struct Hello: Encodable {
    let name: String
}

private func save(resource: Hello) throws {
    let folder = try makeFolder()
    let agent = FileSystemAgent(manager: fileManager)
    let saver = SaveResource(agent: agent, folder: folder)
    try saver.save(resource: resource, withName: "myKey")
}

private func delete(resource: Hello) throws {
    let folder = try makeFolder()
    let agent = FileSystemAgent(manager: fileManager)
    let deleter = DeleteResource(agent: agent, folder: folder)
    try deleter.delete(resourceName: "myKey")
}
```

## Why Use `~Copyable`?

Demo [here](https://tinyurl.com/mpfx4udw)

While the `File` and `Directory` protocols do not require `~Copyable`, it is **strongly recommended** to suppress `Copyable` in conforming types. This prevents unintended copies of objects that represent real-world file system entities. By ensuring instances are non-copyable:

- **Resource Integrity**: Prevents duplicated instances representing the same file system object.
- **Correct Mutations**: Guarantees modifications (e.g., move or delete) apply to a single, unique instance.
- **Predictable State Management**: Avoids issues where multiple instances might reference the same file, leading to inconsistencies.

## Contributing

Contributions are welcome! If you find any issues or have suggestions, please open a GitHub issue or submit a pull request.

## License

This library is available under the MIT License. See the LICENSE file for more details.
