//
//  BaseBackendOperation.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

enum NetworkError {
    case offlineMode
    case unknownError
    case clientError
    case unauthorized
    case notFound
    case unreachable
}

class BaseBackendOperation: AsyncOperation {
    
    //поле для текущего токена, сохраненнного в UserDefaults
    internal let token = UserDefaults.standard.string(forKey: tokenKey)
    
    // стандартный URLSession кеширует данные и может возвращать неактуальную ссылку rawUrl
    internal let session: URLSession
    
    override init() {
        //создание URLSession без кеша
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        session = URLSession.init(configuration: config)
        super.init()
    }
    
    //метод для обнуления токена, в случае если в ответ на запрсо пришел код 401
    internal func revokeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
}
