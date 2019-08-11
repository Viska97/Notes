//
//  GistFileContent.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

public struct GistFileContent: Encodable {
    let content: String
    
    init(content: String) {
        self.content = content
    }
}
