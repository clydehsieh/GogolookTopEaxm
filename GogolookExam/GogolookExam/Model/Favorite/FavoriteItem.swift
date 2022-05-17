//
//  FavoriteItem.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

struct FavoriteItem {
    var malID: Int
    var urlString: String?
    var imageURLString: String?
    var rank: Int?
    var start: Date?
    var end: Date?
    var title: String?
}

extension FavoriteItem {
    init(itemEntity: ItemEntity) {
        self.malID = Int(itemEntity.malID)
        self.urlString = itemEntity.url
        self.imageURLString = itemEntity.imageURL
        self.rank = Int(itemEntity.rank)
        self.start = itemEntity.start
        self.end = itemEntity.end
        self.title = itemEntity.title
    }
}
