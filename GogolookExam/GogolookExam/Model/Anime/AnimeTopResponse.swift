//
//  AnimeTopResponse.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

struct AnimeTopResponse: Codable {
    let data: [AnimeData]
    let pagination: Pagination
}

