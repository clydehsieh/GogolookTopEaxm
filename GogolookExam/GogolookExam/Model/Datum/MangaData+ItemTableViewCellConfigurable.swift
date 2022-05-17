//
//  MangaData+ItemTableViewCellConfigurable.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//
import UIKit

extension MangaData: ItemTableViewCellConfigurable {
    var videoURL: URL? {
        URL(string: url)
    }
    
    var imageURL: URL? {
        
        guard let image = images["jpg"] else {
            return nil
        }
        return URL(string: image.imageURL)
    }
    
    var rate: String? {
        "\(rank)"
    }
    var start: String? {
        published?.from?.dateTimeInStr
    }
    var end: String? {
        published?.to?.dateTimeInStr
    }
}
