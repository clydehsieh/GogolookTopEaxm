//
//  MangaType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum MangaType: String, CaseIterable, RequestTypePresentable {
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

extension MangaType: OptionsSelectTableViewCellConfigurable {
    var optionTitle: String {
        rawValue
    }
}
