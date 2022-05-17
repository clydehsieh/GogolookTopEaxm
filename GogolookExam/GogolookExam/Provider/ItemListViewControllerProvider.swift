//
//  ItemListViewControllerProvider.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit


//MARK: - api service
extension ItemListViewControllerProvider {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(OptionalFractionalSecondsDateFormatter())
        return decoder
    }
    
    static var service: ItemApiService {
        ItemApiService(decoder: decoder)
    }
    
    static var viewModel: ViewModelType {
        ViewModel(service: self.service,
                  coreDataStore: self.coreDataStore)
    }
}

//MARK: - local cache service
struct ItemListViewControllerProvider {
    static var coreDataStore: CoreDataStore {
        CoreDataStore()
    }
    
    static var handleItemCacheViewModel: HandleItemCacheViewModelType {
        HandleItemCacheViewModel(coreDataStore: self.coreDataStore)
    }
    
    static var favoriteItemCacheService: FavoriteItemCacheServiceType {
        FavoriteItemCacheService(coreDataStore: self.coreDataStore)
    }
}

//MARK: - ViewController
extension ItemListViewControllerProvider {
    static var viewController: ItemListViewController {
        ItemListViewController(vm: self.viewModel,
                               handleItemCacheViewModel: self.handleItemCacheViewModel,
                               favoriteItemCacheService: self.favoriteItemCacheService)
    }
}
