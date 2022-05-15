//
//  AnimeTopRequest.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

struct AnimeTopRequest: Codable, AnimeTopRequestType {
    let type: AnmineType
    let filter: AnmineFilter
    let page: Int
}

extension AnimeTopRequest {
    static func defaultConfige() -> AnimeTopRequest {
        .init(type: .tv, filter: .tv, page: 0)
    }
}

enum AnmineType: String, Codable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
}

enum AnmineFilter: String, Codable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
}
