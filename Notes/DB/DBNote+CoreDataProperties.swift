//
//  DBNote+CoreDataProperties.swift
//
//
//
//

import Foundation
import CoreData


extension DBNote {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNote> {
        return NSFetchRequest<DBNote>(entityName: "DBNote")
    }
    
    @NSManaged public var color: String?
    @NSManaged public var content: String?
    @NSManaged public var importance: String?
    @NSManaged public var selfDestructDate: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var creationDate: Double
    
}
