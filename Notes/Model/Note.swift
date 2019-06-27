//
//  Note.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

public struct Note {
    public let uid : String
    public let title : String
    public let content : String
    public let color : UIColor
    public let importance : Importance
    public let selfDestructDate : Date?
    
    public init(uid : String = UUID().uuidString,
                title : String,
                content : String,
                color: UIColor = UIColor.white,
                importance : Importance,
                selfDestructDate : Date? = nil) {
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructDate = selfDestructDate
    }
    
    public enum Importance : String {
        case unimportant = "unimportant"
        case normal = "normal"
        case important = "important"
    }
}
