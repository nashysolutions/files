# ``Files``

A lightweight, protocol-oriented library for interacting with the file system in Swift — built for clarity, testability, and composability.

---

The `Files` library provides a modular and testable abstraction over common file system tasks, such as reading, writing, and navigating directories within the app sandbox. It defines clear protocols for files, folders, and operations, allowing you to build flexible storage solutions that are easy to test, extend, or mock.

This library is especially useful for:

- Creating testable file-handling logic using dependency injection
- Managing sandboxed files and directories across Apple platforms
- Isolating platform-specific file system APIs behind clean interfaces

## Design Philosophy

- ✅ **Protocols First** — types like `File`, `Directory`, and `FileSystemContext` abstract over concrete storage
- ✅ **Composable** — use `Folder`, `FileSystemDirectory`, and `FileSystemOperations` together or in isolation
- ✅ **Testable** — mock file operations in unit tests using custom `FileSystemContext` implementations
- ✅ **Portable** — supports iOS, macOS, tvOS, watchOS, and visionOS

## Topics

### Protocols

- ``Directory``
- ``File``
- ``FileSystemContext``
- ``FileSystemOperations``

### Supporting Types

- ``Folder``
- ``FileSystemDirectory``
