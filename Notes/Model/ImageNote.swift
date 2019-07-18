//
//  ImageNote.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

public struct ImageNote {
    public let uid: String
    public let name: String
    public let isDefault: Bool
    
    public init(uid : String = UUID().uuidString, name: String, isDefault: Bool = false){
        self.uid = uid
        self.name = name
        self.isDefault = isDefault
    }
}

public extension ImageNote {
    
    static func parse(json: [String: Any]) -> ImageNote? {
        if let uid = (json["uid"] as? String),
            let name: String = (json["name"] as? String) {
            if let isDefault = (json["default"] as? Bool) {
                return ImageNote(uid: uid, name: name, isDefault: isDefault)
            }
            else{
                return ImageNote(uid: uid, name: name)
            }
        }
        else{
            return nil
        }
    }
    
    var json: [String: Any] {
        var result = [String: Any]()
        result["uid"] = self.uid
        result["name"] = self.name
        if(isDefault){
            result["default"] = true
        }
        return result
    }
    
    var path: String {
        if isDefault, let bundlePath = Bundle.main.path(forResource: "DefaultImageNotes", ofType: nil) {
            return bundlePath + "/" + name
        }
        else {
            let cachesPath = FileManager.default.temporaryDirectory.path
            return cachesPath + "/" + name
        }
    }
}
