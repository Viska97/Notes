//
//  BaseDBOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {
    let backgroundContext: NSManagedObjectContext
    
    init(backgroundContext: NSManagedObjectContext) {
        self.backgroundContext = backgroundContext
        super.init()
    }
}
