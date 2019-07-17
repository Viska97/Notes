//
//  FileNotebook.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class FileNotebook {
    
    public private(set) var notes = [Note]()
    
    public init(){}
    
    public func add(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.uid == note.uid }) {
            //если заметка с таким uid уже существует, заменяем ее по индексу
            DDLogDebug("Updated note with uid: \(note.uid))")
            notes[index] = note
        }
        else{
            //если не существует, просто добавляем
            DDLogDebug("Added note with uid: \(note.uid))")
            notes.append(note)
        }
    }
    
    public func remove(with uid: String) {
        if let index = notes.firstIndex(where: { $0.uid == uid }) {
            //находим индекс заметки и удаляем ее по индексу
            DDLogDebug("Removed note with uid: \(notes[index].uid))")
            notes.remove(at: index)
        }
    }
    
    public func saveToFile() {
        if let directoryUrl = directoryUrl {
            let fileUrl = directoryUrl.appendingPathComponent(fileName)
            var json = [Dictionary<String, Any>]()
            for note in notes {
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
                DDLogInfo("Notes saved to file", level: logLevel)
            }
            catch {
                DDLogError("Exception while saving notes to file", level: logLevel)
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
                        notes.removeAll()
                        for item in json {
                            if let note = Note.parse(json: item) {
                                add(note)
                            }
                        }
                        DDLogInfo("Notes loaded from file", level: logLevel)
                    }
                }
                else {
                    notes = FileNotebook.defaultNotes()
                    DDLogInfo("File not exists. Fill collection with initial notes", level: logLevel)
                }
            }
            catch {
                DDLogError("Exception while loading notes from file", level: logLevel)
            }
        }
    }
    
    //имя файла
    private let fileName = "notes.json"
    
    //вычисляемое поле для получения пути к папке, где будет сохранен файл
    private var directoryUrl : URL? {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return cachesDirectory?.appendingPathComponent("Files")
    }
    
    private static func defaultNotes() -> [Note] {
        return [
            Note(uid: "1", title: "Заголовок заметки", content: "Текст заметки, Текст заметки, Текст заметки, Текст заметки, Текст заметки", color: .red, importance: .normal, selfDestructDate: nil),
            Note(uid: "2", title: "Короткая заметка", content: "Текст", color: .green, importance: .normal, selfDestructDate: nil),
            Note(uid: "3", title: "Длинная заметка", content: "Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки, Длинный текст заметки", color: .blue, importance: .normal, selfDestructDate: nil),
            Note(uid: "4", title: "3аголовок заметки - 2", content: "Текст заметки, Текст заметки, Текст заметки, Текст заметки, Текст заметки", color: .yellow, importance: .normal, selfDestructDate: nil),
            Note(uid: "5", title: "Короткая заметка", content: "Не забыть выключить утюг", color: .cyan, importance: .normal, selfDestructDate: nil)
        ]
    }
    
}
