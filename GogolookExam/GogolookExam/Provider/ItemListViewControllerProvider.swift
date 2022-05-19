//
//  ItemListViewControllerProvider.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

struct ItemListViewControllerProvider { }

//MARK: - api service
extension ItemListViewControllerProvider {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(OptionalFractionalSecondsDateFormatter())
        return decoder
    }
    
    static var networkManager: NetworkManager {
        NetworkManager.share
    }
}

//MARK: - ViewModel
extension ItemListViewControllerProvider {
    static var viewModel: ViewModelType {
        let coreDataStore = CoreDataStore.shared
        let itemCacheService = FavoriteItemCacheService(coreDataStore: coreDataStore)
        
        return ViewModel(networkManager: self.networkManager,
                         itemCacheService: itemCacheService)
    }
}


//MARK: - ViewController
extension ItemListViewControllerProvider {
    static var viewController: ItemListViewController {
        ItemListViewController(vm: self.viewModel)
    }
}
