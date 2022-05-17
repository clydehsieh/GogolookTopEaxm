//
//  MangaData.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

// MARK: - Datum
struct MangaData: Codable {
    let malID: Int
    let title: String?
    let url: String
    let images: [String: Image]
    let published: Published?
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case malID = "mal_id"
        case title, url, images, published, rank 
    }
}

// MARK: - Aired
struct Published: Codable {
    let from, to: Date?
}
