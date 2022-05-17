//
//  MangaFilter.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum MangaFilter: String, CaseIterable {
    case none
    case publishing
    case upcoming
    case bypopularity
    case favorite
}

extension MangaFilter: RequestFilterPresentable {
    var value: String? {
        return self == .none ? nil : rawValue
    }
}

extension MangaFilter: OptionsSelectTableViewCellConfigurable {
    var optionTitle: String {
        rawValue
    }
}
