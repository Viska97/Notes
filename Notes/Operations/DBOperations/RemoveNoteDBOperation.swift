//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {
    private let uid: String
    
    init(uid: String,
         backgroundContext: NSManagedObjectContext) {
        self.uid = uid
        super.init(backgroundContext: backgroundContext)
    }
    
    override func main() {
        let request = NSFetchRequest<DBNote>(entityName: "DBNote")
        request.predicate = NSPredicate(format: "uid = %@", uid)
        backgroundContext.performAndWait {
            do {
                let notes = try backgroundContext.fetch(request)
                let noteToDelete = notes[0]
                backgroundContext.delete(noteToDelete)
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
        finish()
    }
}
