//
//  OverrideDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class OverrideNotesDBOperation: BaseDBOperation {
    private let notes: [Note]
    
    init(notes: [Note],
         backgroundContext: NSManagedObjectContext) {
        self.notes = notes
        super.init(backgroundContext: backgroundContext)
    }
    
    override func main() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DBNote")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        backgroundContext.performAndWait {
            do {
                try backgroundContext.execute(deleteRequest)
            } catch {
                print(error)
            }
        }
        for note in notes {
            let newNote = DBNote(context: backgroundContext)
            newNote.uid = note.uid
            newNote.title = note.title
            newNote.content = note.content
            newNote.color = note.hexColor
            newNote.importance = note.importance.rawValue
            if let selfDestructDate = note.selfDestructDate {
                newNote.selfDestructDate = NSNumber(value: selfDestructDate.timeIntervalSince1970)
            }
            else {
                newNote.selfDestructDate = nil
            }
        }
        backgroundContext.performAndWait {
            do {
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
        finish()
    }
}
