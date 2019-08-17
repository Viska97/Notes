//
//  SaveNoteOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: SaveNotesBackendResult? = nil
    
    init(note: Note,
         backgroundContext: NSManagedObjectContext,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        saveToDb = SaveNoteDBOperation(note: note, backgroundContext: backgroundContext)
        self.dbQueue = dbQueue
        
        super.init()
        
        saveToDb.completionBlock = {
            let loadNotes = LoadNotesDBOperation(backgroundContext: backgroundContext)
            loadNotes.completionBlock = {
                let saveToBackend = SaveNotesBackendOperation(notes: loadNotes.result)
                saveToBackend.completionBlock = {
                    self.result = saveToBackend.result
                    self.finish()
                }
                backendQueue.addOperation(saveToBackend)
            }
            dbQueue.addOperation(loadNotes)
        }
    }
    
    override func main() {
        dbQueue.addOperation(saveToDb)
    }
}
