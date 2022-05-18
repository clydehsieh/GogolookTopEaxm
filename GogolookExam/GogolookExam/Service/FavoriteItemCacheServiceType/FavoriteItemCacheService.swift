//
//  FavoriteItemCacheService.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

final class FavoriteItemCacheService {

    let coreDataStore: CoreDataStoreType
    
    var cacheList: [Int] = []
    
    init(coreDataStore: CoreDataStoreType) {
        self.coreDataStore = coreDataStore
        syncCache()
    }
}

//MARK: - fetch
extension FavoriteItemCacheService {
    private func syncCache() {
        if let items = try? fetchItems() {
            cacheList = items.map({ Int($0.malID) })
        }
    }
    
    private func add(malID: Int) {
        if !cacheList.contains(malID) {
            cacheList.append(malID)
            debugPrint("add \(malID)")
        }
    }
    
    private  func delete(malID: Int) {
        if let index = cacheList.firstIndex(where: { $0 == malID }) {
            cacheList.remove(at: index)
            debugPrint("delete \(malID)")
        }
    }
}

//MARK: - fetch/add/remove/isFavorite
extension FavoriteItemCacheService: FavoriteItemCacheServiceType {
    func fetchItems() throws -> [ItemEntity] {
        try coreDataStore.fetchItems()
    }
    
    func isFavorite(malID: Int) -> Bool {
        cacheList.contains(malID)
    }
    
    func handle(data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws {
        do  {
            if let _ = try coreDataStore.fetchItem(malID: data.malID).first {
                // if item exist, then delete
                try coreDataStore.deleteItem(malID: data.malID)
                completion(.deleted(malID: data.malID))
                delete(malID: data.malID)
            } else {
                // else, add item
                try coreDataStore.insertItemEntityData(data: data)
                completion(.saved(malID: data.malID))
                add(malID: data.malID)
            }
        } catch let e {
            completion(.failure(error: e))
        }
    }
}
