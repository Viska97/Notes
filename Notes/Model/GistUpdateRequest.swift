//
//  GistUpdateRequest.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

public struct GistUpdateRequest: Encodable {
    let description: String
    let files: [String: GistFileContent]
    
    init(description: String = "iOS Course Notes Application Database", files: [String: GistFileContent]){
        self.description = description
        self.files = files
    }
    
    static func createGistUpdateRequest(with notes: [Note]) -> Data? {
        var json = [Dictionary<String, Any>]()
        for note in notes {
            let dict = note.json
            json.append(dict)
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {return nil}
        guard let content = String(data: jsonData, encoding: .utf8) else {return nil}
        let files = [backendFile: GistFileContent(content: content)]
        let encoder = JSONEncoder()
        let request = GistUpdateRequest(files: files)
        var data: Data?
        do {
            data = try encoder.encode(request)
        } catch {
            print("Error while encoding GistUpdateRequest")
        }
        return data
    }
}
