//
//  AuthorizationResponse.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

struct AuthorizationResponse: Decodable {
    let token: String
    
    static func parseAuthorizationResponse(with data: Data) -> AuthorizationResponse? {
        var authResponse: AuthorizationResponse?
        let decoder = JSONDecoder()
        do {
            authResponse = try decoder.decode(AuthorizationResponse.self, from: data)
        } catch {
            print("Error while parsing AuthorizationResponse")
        }
        return authResponse
    }
}
