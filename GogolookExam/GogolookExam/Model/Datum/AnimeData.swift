//
//  AnimeData.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

// MARK: - Datum
struct AnimeData: Codable {
    let malID: Int
    let title: String?
    let url: String
    let images: [String: Image]
    let aired: Aired?
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case malID = "mal_id"
        case title, url, images, aired, rank
    }
}

// MARK: - Aired
struct Aired: Codable {
    let from, to: Date?
}

// MARK: - Image
struct Image: Codable {
    let imageURL, smallImageURL, largeImageURL: String

    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case smallImageURL = "small_image_url"
        case largeImageURL = "large_image_url"
    }
}

