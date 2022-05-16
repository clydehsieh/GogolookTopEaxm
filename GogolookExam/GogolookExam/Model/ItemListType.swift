//
//  ItemListType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

enum ItemListType: CaseIterable {
    case anime
    case manga
}

extension ItemListType {
    var displayName: String {
        switch self {
        case .anime:
            return "Anime"
        case .manga:
            return "Manga"
        }
    }
}

extension ItemListType {
    var types: [RequestTypePresentable] {
        switch self {
        case .anime:
            return AnimeType.allCases
        case .manga:
            return MangaType.allCases
        }
    }
    
    var filters: [RequestFilterPresentable] {
        switch self {
        case .anime:
            return AnimeFilter.allCases
        case .manga:
            return MangaFilter.allCases
        }
    }
}
