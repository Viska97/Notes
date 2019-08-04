//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum LoadNotesBackendResult {
    case success([Note])
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
    
    override init() {
        super.init()
    }
    
    override func main() {
        DDLogInfo("Loading notes from backend", level: logLevel)
        //симуляция сетевой задержки
        wait(for: 0.2)
        result = .failure(.unreachable)
        finish()
    }
}

