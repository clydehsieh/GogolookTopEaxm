//
//  FavoriteItemCacheServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

protocol FavoriteItemCacheServiceType {
    func add(malID: Int)
    func remove(malID: Int)
    func isFavorite(malID: Int) -> Bool
}
