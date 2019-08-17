//
//  LoadNotesOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesOperation: AsyncOperation {
    private let loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    
    private(set) var result: [Note]?
    
    init(backgroundContext: NSManagedObjectContext,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        loadFromBackend = LoadNotesBackendOperation()
        self.backendQueue = backendQueue
        
        super.init()
        
        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result! {
            case .success(let notes):
                //заменяем все заметки в БД на заметки от бекенда (сервер всегда прав)
                let overrideDb = OverrideNotesDBOperation(notes: notes, backgroundContext: backgroundContext)
                overrideDb.completionBlock = {
                    self.result = notes
                    self.finish()
                }
                dbQueue.addOperation(overrideDb)
            case .failure:
                let loadFromDb = LoadNotesDBOperation(backgroundContext: backgroundContext)
                loadFromDb.completionBlock = {
                    self.result = loadFromDb.result
                    self.finish()
                }
                dbQueue.addOperation(loadFromDb)
            }
        }
    }
    
    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
    
}
