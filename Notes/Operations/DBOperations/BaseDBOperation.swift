//
//  BaseDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class BaseDBOperation: AsyncOperation {
    let notebook: FileNotebook
    
    init(notebook: FileNotebook) {
        self.notebook = notebook
        super.init()
    }
}
