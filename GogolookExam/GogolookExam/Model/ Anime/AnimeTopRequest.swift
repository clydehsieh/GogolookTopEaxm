//
//  AnimeTopRequest.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

enum AnimeType: String, Codable, RequestTypePresentable {
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

enum AnimeFilter: String, Codable, RequestFilterPresentable {
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
