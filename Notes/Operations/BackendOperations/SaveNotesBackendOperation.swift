//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    let notes: [Note]
    var result: SaveNotesBackendResult?
    
    init(notes: [Note]) {
        self.notes = notes
        super.init()
    }
    
    override func main() {
        DDLogInfo("Saving notes to backend", level: logLevel)
        saveNotes()
    }
    
    private func saveNotes() {
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
                if let id = gists.first(where: { $0.files[backendFile] != nil})?.id {
                    //если gist с файлом ios-course-notes-db существует, обновляем его
                    self.updateGist(with: id)
                }
                else {
                    //иначе создаем новый gist с файлом ios-course-notes-db
                    self.createGist()
                }
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
    
    //создание нового gist
    private func createGist() {
        guard let url = URL(string: "https://api.github.com/gists"), let token = token else {
            result = .failure(.clientError)
            finish()
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = GistUpdateRequest.createGistUpdateRequest(with: notes)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            var result: SaveNotesBackendResult?
            defer{
                self.result = result
                self.finish()
            }
            guard let response = response as? HTTPURLResponse else {
                result = .failure(.unreachable)
                return
            }
            switch response.statusCode {
            case 201:
                DDLogInfo("Notes saved to backend", level: logLevel)
                result = .success
            case 401:
                self.revokeToken()
                result = .failure(.unauthorized)
            default:
                result = .failure(.unknownError)
            }
        }
        task.resume()
    }
    
    //обновление существующего gist
    private func updateGist(with id: String) {
        guard let url = URL(string: "https://api.github.com/gists/\(id)"), let token = token else {
            result = .failure(.clientError)
            finish()
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = GistUpdateRequest.createGistUpdateRequest(with: notes)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            var result: SaveNotesBackendResult?
            defer{
                self.result = result
                self.finish()
            }
            guard let response = response as? HTTPURLResponse else {
                result = .failure(.unreachable)
                return
            }
            switch response.statusCode {
            case 200:
                DDLogInfo("Notes saved to backend", level: logLevel)
                result = .success
            case 401:
                self.revokeToken()
                result = .failure(.unauthorized)
            default:
                result = .failure(.unknownError)
            }
        }
        task.resume()
    }
}
