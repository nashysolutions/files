//
//  MockResource.swift
//  files
//
//  Created by Robert Nash on 09/01/2025.
//

import Foundation
import Files

struct MockResource: File, ~Copyable {
    let name: String
    let enclosingFolder: MockFolder
}
