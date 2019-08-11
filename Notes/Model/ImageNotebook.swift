//
//  ImageNotebook.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

class ImageNotebook {
    
    public private(set) var imageNotes = [ImageNote]()
    
    public func add(_ imageNote: ImageNote) {
        if let index = imageNotes.firstIndex(where: { $0.uid == imageNote.uid }) {
            //если заметка с таким uid уже существует, заменяем ее по индексу
            DDLogDebug("Updated image note with uid: \(imageNote.uid)")
            imageNotes[index] = imageNote
        }
        else{
            //если не существует, просто добавляем
            DDLogDebug("Added image note with uid: \(imageNote.uid)")
            imageNotes.append(imageNote)
        }
    }
    
    public func remove(with uid: String) {
        if let index = imageNotes.firstIndex(where: { $0.uid == uid }) {
            //находим индекс заметки и удаляем ее по индексу
            DDLogDebug("Removed image note with uid: \(imageNotes[index].uid)")
            imageNotes.remove(at: index)
        }
    }
    
    public func saveToFile() {
        if let directoryUrl = directoryUrl {
            let fileUrl = directoryUrl.appendingPathComponent(fileName)
            var json = [Dictionary<String, Any>]()
            for note in imageNotes {
                let dict = note.json
                json.append(dict)
            }
            do {
                var isDir : ObjCBool = true
                if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: &isDir), isDir.boolValue {
                    try FileManager.default.createDirectory(atPath: directoryUrl.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                }
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                try data.write(to: fileUrl, options: [])
                DDLogInfo("Image notes saved to file", level: logLevel)
            }
            catch {
                DDLogError("Exception while saving image notes to file", level: logLevel)
            }
        }
    }
    
    public func loadFromFile() {
        if let directoryUrl = directoryUrl {
            let fileUrl = directoryUrl.appendingPathComponent(fileName)
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    let data = try Data(contentsOf: fileUrl)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let json = json as? [Dictionary<String, Any>] {
                        // в требованиях не прописано, следует ли удалять текущие записки(если они есть) перед загрузкой из файла
                        // условимся, что нужно удалять, поэтому пропишем notes.removeAll()
                        imageNotes.removeAll()
                        for item in json {
                            if let note = ImageNote.parse(json: item){
                                add(note)
                            }
                        }
                        DDLogInfo("Image notes loaded from file", level: logLevel)
                    }
                }
                else {
                    imageNotes = ImageNotebook.defaultImageNotes()
                    DDLogInfo("File not exists. Fill collection with initial image notes", level: logLevel)
                }
            }
            catch {
                DDLogError("Exception while loading image notes from file", level: logLevel)
            }
        }
    }
    
    //имя файла
    private let fileName = "imagenotes.json"
    
    //вычисляемое поле для получения пути к папке, где будет сохранен файл
    private var directoryUrl : URL? {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return cachesDirectory?.appendingPathComponent("Files")
    }
    
    private static func defaultImageNotes() -> [ImageNote] {
        return [
            ImageNote(name: "Sunrise.png", isDefault: true),
            ImageNote(name: "SunriseOverMountains.png", isDefault: true),
            ImageNote(name: "Sparkler.png", isDefault: true),
            ImageNote(name: "Fireworks.png", isDefault: true),
            ImageNote(name: "Sunset.png", isDefault: true),
            ImageNote(name: "CityscapeAtDusk.png", isDefault: true),
            ImageNote(name: "Cityscape.png", isDefault: true),
            ImageNote(name: "NightWithStars.png", isDefault: true),
            ImageNote(name: "MilkyWay.png", isDefault: true),
            ImageNote(name: "BridgeAtNight.png", isDefault: true),
            ImageNote(name: "Foggy.png", isDefault: true)
        ]
    }
    
}
