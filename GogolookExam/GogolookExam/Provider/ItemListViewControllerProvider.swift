//
//  ItemListViewControllerProvider.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

struct ItemListViewControllerProvider {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(OptionalFractionalSecondsDateFormatter())
        return decoder
    }
    static var service: ItemApiService {
        ItemApiService(decoder: decoder)
    }
    
    static var viewModel: ViewModelType {
        ViewModel(service: self.service)
    }
}

extension ItemListViewControllerProvider {
    static var viewController: ItemListViewController {
        ItemListViewController(vm: self.viewModel)
    }
}
