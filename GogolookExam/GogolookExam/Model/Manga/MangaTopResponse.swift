//
//  MangaTopResponse.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

struct MangaTopResponse: Codable {
    let data: [MangaData]
    let pagination: Pagination
}
