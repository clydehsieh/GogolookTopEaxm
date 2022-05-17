//
//  FavoriteItem+ItemTableViewCellConfigurable.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

extension FavoriteItem: ItemTableViewCellConfigurable {
    
    var videoURL: URL? {
        urlString?.url
    }
    
    var imageURL: URL? {
        imageURLString?.url
    }
}
