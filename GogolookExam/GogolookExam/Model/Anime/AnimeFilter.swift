//
//  AnimeFilter.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum AnimeFilter: String, CaseIterable {
    case none
    case airing
    case upcoming
    case bypopularity
    case favorite
}

extension AnimeFilter: RequestFilterPresentable {
    var value: String? {
        return self == .none ? nil : rawValue
    }
}

extension AnimeFilter: OptionsSelectTableViewCellConfigurable {
    var optionTitle: String {
        rawValue
    }
}
