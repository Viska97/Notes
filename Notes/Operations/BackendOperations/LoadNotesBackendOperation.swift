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
        if(token != offlineToken){
            DDLogInfo("Loading notes from backend", level: logLevel)
            loadNotes()
        }
        else{
            result = .failure(.offlineMode)
            finish()
        }
    }
    
    private func loadNotes() {
        guard let url = URL(string: "https://api.github.com/gists"), let token = token else {
            result = .failure(.clientError)
            finish()
            return
        }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            guard let response = response as? HTTPURLResponse else {
                self.result = .failure(.unreachable)
                self.finish()
                return
            }
            switch response.statusCode {
            case 200:
                guard let data = data else {
                    self.result = .failure(.unknownError)
                    self.finish()
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let gists = try? decoder.decode([Gist].self, from: data) else {
                    self.result = .failure(.unknownError)
                    self.finish()
                    return
                }
                //здесь получаем ссылку rawUrl на файл ios-course-notes-db или nil если такого файла в gists не существует
                let rawUrl = gists.first(where: { $0.files[backendFile] != nil})?.files[backendFile]?.rawUrl
                //загружаем заметки из файла по ссылке
                self.loadNotesFromGistFile(with: rawUrl)
            case 401:
                self.revokeToken()
                self.result = .failure(.unauthorized)
                self.finish()
            default:
                self.result = .failure(.unknownError)
                self.finish()
            }
        }
        task.resume()
    }
    
    private func loadNotesFromGistFile(with rawUrl: String?) {
        guard let rawUrl = rawUrl else {
            //если файл не существует возвращаем ошибку notFound
            result = .failure(.notFound)
            finish()
            return
        }
        guard let url = URL(string: rawUrl) else {
            result = .failure(.clientError)
            finish()
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            var result: LoadNotesBackendResult?
            defer {
                self.result = result
                self.finish()
            }
            guard let response = response as? HTTPURLResponse else {
                result = .failure(.unreachable)
                return
            }
            switch response.statusCode {
            case 200:
                guard let data = data else {
                    result = .failure(.unknownError)
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let noteItems = json as? [Dictionary<String, Any>] else {
                    result = .failure(.unknownError)
                    return
                }
                var notes = [Note]()
                for item in noteItems {
                    if let note = Note.parse(json: item) {
                        notes.append(note)
                    }
                }
                DDLogInfo("Notes loaded from backend", level: logLevel)
                result = .success(notes)
            default:
                result = .failure(.unknownError)
            }
        }
        task.resume()
    }
}
