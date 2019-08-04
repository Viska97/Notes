//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    
    init(note: Note,
         notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.add(note)
        notebook.saveToFile()
        finish()
    }
}
