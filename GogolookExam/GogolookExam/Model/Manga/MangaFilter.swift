//
//  MangaFilter.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum MangaFilter: String, CaseIterable, RequestFilterPresentable {
    case none
    case publishing
    case upcoming
    case bypopularity
    case favorite
    
    var value: String? {
        return self == .none ? nil : rawValue
    }
}
