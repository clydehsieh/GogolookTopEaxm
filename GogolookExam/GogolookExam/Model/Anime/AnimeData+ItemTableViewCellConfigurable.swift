//
//  Data+ItemTableViewCellConfigurable.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

extension AnimeData: ItemTableViewCellConfigurable {

    var videoURL: URL? {
        URL(string: url)
    }
    
    var imageURL: URL? {
        
        guard let image = images["jpg"] else {
            return nil
        }
        return URL(string: image.imageURL)
    }
    
    var start: Date? {
        aired?.from
    }
    var end: Date? {
        aired?.to
    }
}
