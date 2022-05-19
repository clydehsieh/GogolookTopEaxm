//
//  Pagination.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

struct Pagination: Codable {
    let lastVisiblePage: Int
    let hasNextPage: Bool
    let currentPage: Int
    let items: Items

    enum CodingKeys: String, CodingKey {
        case lastVisiblePage = "last_visible_page"
        case hasNextPage = "has_next_page"
        case currentPage = "current_page"
        case items
    }
}

extension Pagination {
    static var defaultConfig: Pagination = .init(lastVisiblePage: 1, hasNextPage: true, currentPage: 0, items: .init(count: 0, total: 0, perPage: 0))
}


// MARK: - Items
struct Items: Codable {
    let count, total, perPage: Int

    enum CodingKeys: String, CodingKey {
        case count, total
        case perPage = "per_page"
    }
}
