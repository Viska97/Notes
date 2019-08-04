//
//  BaseBackendOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

enum NetworkError {
    case unreachable
}

class BaseBackendOperation: AsyncOperation {
    override init() {
        super.init()
    }
}
