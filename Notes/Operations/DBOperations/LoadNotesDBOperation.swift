//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

class LoadNotesDBOperation: BaseDBOperation {
    var result: [Note]?
    
    override init(notebook: FileNotebook) {
        super.init(notebook: notebook)
    }
    
    override func main() {
        DDLogInfo("Loading notes from db", level: logLevel)
        notebook.loadFromFile()
        result = notebook.notes
        finish()
    }
}
