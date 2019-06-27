//
//  NoteExtension.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

public extension Note {
    
    static func parse(json: [String: Any]) -> Note? {
        if let uid = (json["uid"] as? String),
            let title = (json["title"] as? String),
            let content = (json["content"] as? String) {
            var color = UIColor.white
            if let hexString = (json["color"] as? String) {
                color = self.convertToColor(hexString: hexString)
            }
            let importance = Importance(rawValue: (json["importance"] as? String) ?? "") ?? Importance.normal
            var selfDestructDate : Date? = nil
            if let date = (json["selfDestructDate"] as? Double) {
                selfDestructDate = Date(timeIntervalSince1970: TimeInterval(date))
            }
            return Note(uid: uid,
                        title: title,
                        content: content,
                        color: color,
                        importance: importance,
                        selfDestructDate: selfDestructDate)
        }
        else{
            return nil
        }
    }
    
    var json: [String: Any] {
        var result = [String: Any]()
        result["uid"] = self.uid
        result["title"] = self.title
        result["content"] = self.content
        if(self.color != UIColor.white){
            result["color"] = self.hexColor
        }
        if(self.importance != Importance.normal) {
            result["importance"] = self.importance.rawValue
        }
        if let selfDestructDate = self.selfDestructDate {
            result["selfDestructDate"] = Double(selfDestructDate.timeIntervalSince1970)
        }
        return result
    }
    
    //функция для получения UIColor из hex строки
    private static func convertToColor(hexString : String) -> UIColor {
        guard hexString.hasPrefix("#") && hexString.count == 9 else {
            return UIColor.white
        }
        let scanner = Scanner(string : hexString)
        scanner.scanLocation = 1
        var hexColor:  UInt32 = 0
        guard scanner.scanHexInt32(&hexColor) else {
            return UIColor.white
        }
        let mask = CGFloat(255)
        let r = CGFloat((hexColor & 0xFF000000) >> 24) / mask
        let g = CGFloat((hexColor & 0x00FF0000) >> 16) / mask
        let b = CGFloat((hexColor & 0x0000FF00) >> 8) / mask
        let a = CGFloat(hexColor & 0x000000FF) / mask
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    //вычисляемое поле для получения цвета в виде hex строки
    private var hexColor : String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X%02X",
                      Int(round(r * 255)), Int(round(g * 255)),
                      Int(round(b * 255)), Int(round(a * 255)))
    }
    
}
