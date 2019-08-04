//
//  AsyncOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    private var _executing = false
    private var _finished = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        willChangeValue(forKey: "isExecuting")
        _executing = true
        main()
        didChangeValue(forKey: "isExecuting")
    }
    
    override func main() {
        fatalError("Should be overriden")
    }
    
    func finish() {
        willChangeValue(forKey: "isFinished")
        _finished = true
        didChangeValue(forKey: "isFinished")
    }
}

//Реализация аналога функции sleep из самостоятельного задания
func wait(for interval: TimeInterval) {
    let group = DispatchGroup()
    group.enter()
    DispatchQueue.global().asyncAfter(deadline: .now() + interval, execute: {
        group.leave()
    })
    group.wait()
}
