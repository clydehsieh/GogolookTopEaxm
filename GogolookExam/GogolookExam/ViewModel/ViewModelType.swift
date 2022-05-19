//
//  ViewModelType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

enum HandleItemCacheResult {
    case saved(malID: Int)
    case deleted(malID: Int)
    case failure(error: Error)
}

enum RequestType {
    case anime(param: ItemRequestType)
    case manga(param: ItemRequestType)
    case favorite
}

enum LoadingState {
    case loadNewListType
    case loadNewParamType
    case loadNewParamFilter
    case loadNewPage
    case idle
    
    func isAnimation() -> Bool {
        self != .idle
    }
}

protocol ViewModelType {
    // state
    var loadingState: CurrentValueSubject<LoadingState, Never> { get }

    // output
    var updateItemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> { get }
    var updatePagnationSubject: CurrentValueSubject<Pagination?, Never> { get }
    
    // input
    var currentListType: CurrentValueSubject<ItemListType, Never> { get }
    var currentParamType: CurrentValueSubject<String?, Never> { get }
    var currentParamFilter: CurrentValueSubject<String?, Never> { get }
    var currentPage: CurrentValueSubject<Int, Never> { get }
    var hasNexPage: Bool {get}
    
    func isFavorite(malID: Int) -> Bool 
    func didTapFavorite(at data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws
}
