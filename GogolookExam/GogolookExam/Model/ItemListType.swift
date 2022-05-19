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
    case favorite
}

extension ItemListType {
    static let defaultType = ItemListType.anime
    
    var segmentFirst: Bool {
        self == .anime
    }
    
    var deleteDataWhenUnfavorite: Bool {
        self == .favorite
    }
    
    var enableSeletOptionSegmentView: Bool {
        self != .favorite
    }
    
    var isPageable: Bool {
        self != .favorite
    }
}

extension ItemListType {
    var displayName: String {
        switch self {
        case .anime:
            return "Anime"
        case .manga:
            return "Manga"
        case .favorite:
            return "Favorite"
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
        default:
            return []
        }
    }
    
    var filters: [RequestFilterPresentable] {
        switch self {
        case .anime:
            return AnimeFilter.allCases
        case .manga:
            return MangaFilter.allCases
        default:
            return []
        }
    }
}

extension ItemListType {
    var optionTypes: [OptionsSelectTableViewCellConfigurable] {
        switch self {
        case .anime:
            return AnimeType.allCases
        case .manga:
            return MangaType.allCases
        default:
            return []
        }
    }
    
    var optionFilters: [OptionsSelectTableViewCellConfigurable] {
        switch self {
        case .anime:
            return AnimeFilter.allCases
        case .manga:
            return MangaFilter.allCases
        default:
            return []
        }
    }
}


