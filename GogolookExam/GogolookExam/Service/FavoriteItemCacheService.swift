//
//  FavoriteItemCacheService.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

final class FavoriteItemCacheService {

    let coreDataStore: CoreDataStore
    
    var cacheList: [Int] = []
    
    init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
        fetchCache()
    }
}

extension FavoriteItemCacheService: FavoriteItemCacheServiceType {
    func add(malID: Int) {
        if !cacheList.contains(malID) {
            cacheList.append(malID)
            debugPrint("add \(malID)")
        }
    }
    
    func remove(malID: Int) {
        if let index = cacheList.firstIndex(where: { $0 == malID }) {
            cacheList.remove(at: index)
            debugPrint("delete \(malID)")
        }
    }
    
    func isFavorite(malID: Int) -> Bool {
        cacheList.contains(malID)
    }
}

extension FavoriteItemCacheService {
    private func fetchCache() {
        if let items = try? coreDataStore.fetchItems() {
            cacheList = items.map({ Int($0.malID) })
        }
    }
}
