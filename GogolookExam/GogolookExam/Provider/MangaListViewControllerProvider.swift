//
//  MangaListViewControllerProvider.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//
struct MangaListViewControllerProvider {
    static var service: MangaApiServiceType {
        MangaApiService()
    }
    
    static var viewModel: MangaViewModelType {
        MangaViewModel(service: self.service)
    }
    
    static var viewcontroller: MangaListViewController {
        MangaListViewController(vm: self.viewModel)
    }
}
