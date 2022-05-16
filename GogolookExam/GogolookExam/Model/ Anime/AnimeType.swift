//
//  AnimeType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

enum AnimeType: String, CaseIterable, RequestTypePresentable {
    case none
    case tv
    case movie
    case ova
    case special
    case ona
    case music
    
    var value: String? {
        return self == .none ? nil : rawValue
    }
}
