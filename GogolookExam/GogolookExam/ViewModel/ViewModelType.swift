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

protocol ViewModelType {
    // state
    var requestCache: ItemRequest { get set }
    var isLoading: CurrentValueSubject<Bool, Never> { get }

    // output
    var updateItemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> { get }
    
    // input
    var changeListTypeEvent: PassthroughSubject<ItemListType, Never> { get }
    var changeParamTypeEvent: PassthroughSubject<String?, Never> { get }
    var changeParamFilterEvent: PassthroughSubject<String?, Never> { get }
    var requestNextPageEvent: PassthroughSubject<Void, Never> { get }
    
    func isFavorite(malID: Int) -> Bool 
    func didTapFavorite(at data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws
}
