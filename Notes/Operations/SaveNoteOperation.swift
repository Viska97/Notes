//
//  SaveNoteOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: SaveNotesBackendResult? = nil
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
        self.dbQueue = dbQueue
        
        super.init()
        
        saveToDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
            saveToBackend.completionBlock = {
                self.result = saveToBackend.result
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
    }
    
    override func main() {
        dbQueue.addOperation(saveToDb)
    }
}
