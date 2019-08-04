//
//  RemoveNoteOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class RemoveNoteOperation: AsyncOperation {
    private let removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: Bool? = false
    
    init(uid: String,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        removeFromDb = RemoveNoteDBOperation(uid: uid, notebook: notebook)
        self.dbQueue = dbQueue
        
        super.init()
        
        removeFromDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
            saveToBackend.completionBlock = {
                switch saveToBackend.result! {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                }
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
    }
    
    override func main() {
        dbQueue.addOperation(removeFromDb)
    }
}
