//
//  MangeTopRequest.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

protocol MangaTopRequestType {
    var type: MangeType { get }
    var filter: MangeFilter { get }
    var page: Int { get }
}

struct MangeTopRequest: Codable, MangaTopRequestType {
    let type: MangeType
    let filter: MangeFilter
    let page: Int
}

extension MangeTopRequest {
    static func defaultConfige() -> MangeTopRequest {
        .init(type: .manga, filter: .publishing, page: 0)
    }
}

enum MangeType: String, Codable, RequestTypePresentable {
    case none
    case manga
    case novel
    case lightnovel
    case oneshot
    case doujin
    case manhwa
    case manhua
    
    var value: String? {
        return self == .none ? nil : rawValue
    }
}

enum MangeFilter: String, Codable, RequestFilterPresentable {
    case none
    case publishing
    case upcoming
    case bypopularity
    case favorite
    
    var value: String? {
        return self == .none ? nil : rawValue
    }
}