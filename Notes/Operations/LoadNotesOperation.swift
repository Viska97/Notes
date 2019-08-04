//
//  LoadNotesOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class LoadNotesOperation: AsyncOperation {
    private let loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    
    private(set) var result: [Note]?
    
    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        loadFromBackend = LoadNotesBackendOperation()
        self.backendQueue = backendQueue
        
        super.init()
        
        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result! {
            case .success(let notes):
                //добавляем все заметки в notebook. Все заметки с одинаковым uid будут перезаписаны
                notebook.addAll(notes)
                //затем сохраняем все в файл
                notebook.saveToFile()
                self.result = notes
            case .failure:
                let loadFromDb = LoadNotesDBOperation(notebook: notebook)
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
