//
//  FavoriteItemCacheServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

protocol FavoriteItemCacheServiceType {
    func isFavorite(malID: Int) -> Bool
    
    func fetchItems() throws -> [ItemEntity]
    func handle(data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws
}
