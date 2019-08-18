//
//  Gist.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

struct Gist: Decodable {
    let id: String
    let files: [String:GistFile]
    let createdAt: Date
    let description: String?
    let comments: Int
    let commentsUrl: String
}
