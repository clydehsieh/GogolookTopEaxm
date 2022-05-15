//
//  AnimeListViewControllerProvider.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

struct AnimeListViewControllerProvider {
    static var service: ApiServiceType {
        ApiService()
    }
    
    static var viewModel: ViewModelType {
        ViewModel(service: self.service)
    }
    
    static var viewcontroller: AnimeListViewController {
        AnimeListViewController(vm: self.viewModel)
    }
}
