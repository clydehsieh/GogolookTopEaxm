//
//  AnimeFilter.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum AnimeFilter: String, CaseIterable {
    case none
    case tv
    case movie
    case ova
    case special
    case ona
    case music
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
