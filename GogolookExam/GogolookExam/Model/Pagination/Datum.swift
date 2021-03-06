//
//  AnimeData.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import CoreGraphics

// MARK: - Datum
struct AnimeData: Codable {
    let malID: Int
    let title: String?
    let url: String
    let images: [String: Image]
    let aired: Aired?
    let rank: Int
    
//    let trailer: Trailer?
//    let titleEnglish, titleJapanese: String?
//    let titleSynonyms: [String]
//    let type, source: String?
//    let episodes: Int?
//    let status: String
//    let airing: Bool?
//    let duration, rating: String?
//    let score: CGFloat // float not int
//    let scoredBy, popularity: Int
//    let members, favorites: Int
//    let background: String? // optional
//    let synopsis, season: String?
//    let year: Int?
//    let broadcast: Broadcast?
//    let producers, licensors, studios, genres: [Demographic]?
//    let explicitGenres, themes, demographics: [Demographic]?

    enum CodingKeys: String, CodingKey {
        case malID = "mal_id"
        case title, url, images, aired, rank
//        case trailer
//        case titleEnglish = "title_english"
//        case titleJapanese = "title_japanese"
//        case titleSynonyms = "title_synonyms"
//        case type, source, episodes, status, airing, duration, rating, score
//        case scoredBy = "scored_by"
//        case popularity, members, favorites, synopsis, background, season, year, broadcast, producers, licensors, studios, genres
//        case explicitGenres = "explicit_genres"
//        case themes, demographics
    }
}

// MARK: - Aired
struct Aired: Codable {
    let from, to: Date?
//    let prop: Prop
}

// MARK: - Prop
//struct Prop: Codable {
//    let from, to: From?
//    let string: String?
//}

// MARK: - From
//struct From: Codable {
//    let day, month, year: Int?
//}

//// MARK: - Broadcast
//struct Broadcast: Codable {
//    let day, time, timezone, string: String?
//}
//
//// MARK: - Demographic
//struct Demographic: Codable {
//    let malID: Int
//    let type, name, url: String
//
//    enum CodingKeys: String, CodingKey {
//        case malID = "mal_id"
//        case type, name, url
//    }
//}

// MARK: - Image
struct Image: Codable {
    let imageURL, smallImageURL, largeImageURL: String

    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case smallImageURL = "small_image_url"
        case largeImageURL = "large_image_url"
    }
}

// MARK: - Trailer
//struct Trailer: Codable {
//    let youtubeID, url, embedURL: String?
//
//    enum CodingKeys: String, CodingKey {
//        case youtubeID = "youtube_id"
//        case url
//        case embedURL = "embed_url"
//    }
//}


