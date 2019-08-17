//
//  RemoveNoteOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {
    private let removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: SaveNotesBackendResult? = nil
    
    init(uid: String,
         backgroundContext: NSManagedObjectContext,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        removeFromDb = RemoveNoteDBOperation(uid: uid, backgroundContext: backgroundContext)
        self.dbQueue = dbQueue
        
        super.init()
        
        removeFromDb.completionBlock = {
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
        dbQueue.addOperation(removeFromDb)
    }
}
