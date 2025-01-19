# Files
  
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)  
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20visionOS%20%7C%20tvOS%20%7C%20watchOS-blue)

A lightweight Swift library for managing file system resources in a protocol-oriented manner.

Features
	•	Defines protocols for file system entities: File and Directory
	•	Provides convenience methods for reading, writing, copying, and deleting files
	•	Supports a FileSystemContext abstraction for file operations
	•	Encourages non-copyable (~Copyable) implementations to maintain resource integrity

Installation

You can add this library to your Swift project using Swift Package Manager.

Swift Package Manager
	1.	Open your Xcode project.
	2.	Go to File → Add Packages.
	3.	Enter the repository URL:
	4.	Select the appropriate version and add it to your project.

```
https://github.com/nashysolutions/files.git
```

## Getting Started

Creating Concrete Types

To work with files and directories, define your own concrete types conforming to File and Directory.

> **Important**: While Directory and File do not enforce ~Copyable, it is strongly recommended to adopt ~Copyable to avoid unintended duplication of resources.

```swift
struct Folder: Directory, ~Copyable {
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

## Why Use ~Copyable?

While the File and Directory protocols do not require ~Copyable, it is strongly recommended to suppress Copyable in conforming types. This prevents unintended copies of objects that represent real-world file system entities. By ensuring instances are non-copyable:
	•	Resource Integrity: Prevents duplicated instances representing the same file system object.
	•	Correct Mutations: Guarantees modifications (e.g., move or delete) apply to a single, unique instance.
	•	Predictable State Management: Avoids issues where multiple instances might reference the same file, leading to inconsistencies.

## Contributing

Contributions are welcome! If you find any issues or have suggestions, please open a GitHub issue or submit a pull request.

## License

This library is available under the MIT License. See the LICENSE file for more details.
