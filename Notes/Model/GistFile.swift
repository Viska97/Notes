//
//  GistFile.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import Foundation

public struct GistFile: Decodable {
    public let filename: String
    public let rawUrl: String
}

public let backendFile = "ios-course-notes-db"
