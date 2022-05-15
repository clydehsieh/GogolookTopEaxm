//
//  AnimeTopRequest.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

protocol AnimeTopRequestType {
    var type: AnimeType { get }
    var filter: AnimeFilter { get }
    var page: Int { get }
}

struct AnimeTopRequest: Codable, AnimeTopRequestType {
    let type: AnimeType
    let filter: AnimeFilter
    let page: Int
}

extension AnimeTopRequest {
    static func defaultConfige() -> AnimeTopRequest {
        .init(type: .tv, filter: .tv, page: 0)
    }
}

enum AnimeType: String, Codable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
}

enum AnimeFilter: String, Codable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
}
