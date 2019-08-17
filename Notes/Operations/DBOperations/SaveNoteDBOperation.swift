//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    
    init(note: Note,
         backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(backgroundContext: backgroundContext)
    }
    
    override func main() {
        let request = NSFetchRequest<DBNote>(entityName: "DBNote")
        request.predicate = NSPredicate(format: "uid = %@", note.uid)
        backgroundContext.performAndWait {
            do {
                let notes = try backgroundContext.fetch(request)
                if(notes.count > 0) {
                    let savedNote = notes[0]
                    savedNote.setValue(note.title, forKey: "title")
                    savedNote.setValue(note.content, forKey: "content")
                    savedNote.setValue(note.hexColor, forKey: "color")
                    savedNote.setValue(note.importance.rawValue, forKey: "importance")
                    if let selfDestructDate = note.selfDestructDate {
                        savedNote.setValue(NSNumber(value: selfDestructDate.timeIntervalSince1970), forKey: "selfDestructDate")
                    }
                    else {
                        savedNote.setValue(nil, forKey: "selfDestructDate")
                    }
                }
                else {
                    let newNote = DBNote(context: backgroundContext)
                    newNote.uid = note.uid
                    newNote.creationDate = Double(Date().timeIntervalSince1970)
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
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
        finish()
    }
}
