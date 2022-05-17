//
//  HandleItemCacheViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

class HandleItemCacheViewModel: HandleItemCacheViewModelType {

    let coreDataStore: CoreDataStore
    
    init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
    }
    
    func handle(data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws {
        
        do  {
            if let _ = try coreDataStore.fetchItem(malID: data.malID).first {
                try coreDataStore.deleteItem(malID: data.malID)
                completion(.deleted(malID: data.malID))
            } else {
                try coreDataStore.insertItemEntityData(data: data)
                completion(.saved(malID: data.malID))
            }
            
            let items = try coreDataStore.fetchItems()
            debugPrint("current favorite items success:\(items.count)")
            
        } catch let e {
            completion(.failure(error: e))
        }
    }
}
