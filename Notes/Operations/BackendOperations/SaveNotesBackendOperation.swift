//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    
    init(notes: [Note]) {
        super.init()
    }
    
    override func main() {
        DDLogInfo("Saving notes to backend", level: logLevel)
        //симуляция сетевой задержки
        wait(for: 0.2)
        result = .failure(.unreachable)
        finish()
    }
}
