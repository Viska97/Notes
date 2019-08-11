//
//  AuthorizationRequest.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

struct AuthorizationRequest: Encodable {
    let scopes: [String]
    let note: String
    let client_id: String
    let client_secret: String
    
    init(scopes: [String] = ["gist"],
         note: String = "iOS Gists Browser",
         client_id: String,
         client_secret: String) {
        self.scopes = scopes
        self.note = note
        self.client_id = client_id
        self.client_secret = client_secret
    }
    
    static func createAuthorizationRequest(
        client_id: String, client_secret: String) -> Data? {
        var data: Data?
        let encoder = JSONEncoder()
        let request = AuthorizationRequest(client_id: client_id, client_secret: client_secret)
        do {
            data = try encoder.encode(request)
        } catch {
            print("Error while encoding AuthorizationRequest")
        }
        return data
    }
}
