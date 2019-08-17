//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class LoadNotesDBOperation: BaseDBOperation {
    var result = [Note]()
    
    override init(backgroundContext: NSManagedObjectContext) {
        super.init(backgroundContext: backgroundContext)
    }
    
    override func main() {
        DDLogInfo("Loading notes from db", level: logLevel)
        let request = NSFetchRequest<DBNote>(entityName: "DBNote")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        backgroundContext.performAndWait {
            do {
                let dbNotes = try backgroundContext.fetch(request)
                for dbNote in dbNotes {
                    if let note = Note.parse(dbNote: dbNote) {
                        result.append(note)
                    }
                }
            } catch {
                print(error)
            }
        }
        finish()
    }
}
