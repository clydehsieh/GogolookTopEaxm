//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

final class ViewModel: ViewModelType {
    //MARK: DI
    let itemCacheService: FavoriteItemCacheServiceType
    let networkManager: NetworkManager
    
    //
    var loadingState: CurrentValueSubject<LoadingState, Never> = .init(.idle)
    
    // output
    private var itemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> = .init([])
    var updateItemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> = .init([])
    var updatePagnationSubject: CurrentValueSubject<Pagination?, Never> = .init(nil)
    
    // input
    var currentListType: CurrentValueSubject<ItemListType, Never> = .init(.anime)
    var currentParamType: CurrentValueSubject<String?, Never> = .init(nil)
    var currentParamFilter: CurrentValueSubject<String?, Never> = .init(nil)
    var currentPage: CurrentValueSubject<Int, Never> = .init(0)
    
    //MARK:
    var subscriptions: Set<AnyCancellable> = .init()
    var hasNexPage: Bool = false
    
    
    init(networkManager: NetworkManager, itemCacheService: FavoriteItemCacheServiceType) {
        self.networkManager = networkManager
        self.itemCacheService = itemCacheService
        
        setupBinding()
    }
    
    private func setupBinding() {
        currentListType
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] type in
                debugPrint("listType to \(type), reset param type & filter to nil, page to 1")
                self?.loadingState.send(.loadNewListType)
                self?.currentParamType.send(nil)
                self?.currentParamFilter.send(nil)
                self?.currentPage.send(1)
                
                self?.request()
            }
            .store(in: &subscriptions)
        
        currentParamType
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] type in
                guard let self = self, self.loadingState.value == .idle else { return }
                debugPrint("param type did change to \(type ?? "nil")")
                self.loadingState.send(.loadNewListType)
                self.currentPage.send(1)
                self.request()
            }
            .store(in: &subscriptions)
        
        currentParamFilter
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] filter in
                guard let self = self, self.loadingState.value == .idle else { return }
                debugPrint("param filter did change to \(filter ?? "nil")")
                self.loadingState.send(.loadNewParamFilter)
                self.currentPage.send(1)
                self.request()
            }
            .store(in: &subscriptions)
        
        currentPage
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] page in
                guard let self = self, self.loadingState.value == .idle else { return }
                debugPrint("param page did change to \(page)")
                self.loadingState.send(.loadNewPage)
                self.request()
            }
            .store(in: &subscriptions)
        
        updatePagnationSubject
            .sink { [weak self] pagination in
                if let page = pagination {
                    self?.hasNexPage = page.hasNextPage
                } else {
                    self?.hasNexPage = false
                }
            }
            .store(in: &subscriptions)
        
        itemListSubject
            .sink { [weak self] items in
                guard let self = self else { return }
                if self.loadingState.value != .loadNewPage {
                    self.updateItemListSubject.send(items)
                } else {
                    self.updateItemListSubject.value.append(contentsOf: items)
                }
                self.loadingState.send(.idle)
            }
            .store(in: &subscriptions)
    }
}

extension ViewModel {
    func request() {
        let param: ItemRequest = .init(type: currentParamType.value,
                                       filter: currentParamFilter.value,
                                       page: currentPage.value)
        
        switch currentListType.value {
        case .anime:
            requestAnime(with: param)
        case .manga:
            requestManga(with: param)
        case .favorite:
            requestFavorite()
        }
    }
    
    private func requestAnime(with param: ItemRequestType) {
        networkManager.request(endPoint: .anime(param: param), responseType: AnimeTopResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let e):
                    debugPrint("e \(e)")
                case .finished: break
                }
            }, receiveValue: { [weak self] response in
                self?.itemListSubject.send(response.data)
                self?.updatePagnationSubject.send(response.pagination)
            })
            .store(in: &subscriptions)
    }
    
    private func requestManga(with param: ItemRequestType) {
        networkManager.request(endPoint: .manga(param: param), responseType: MangaTopResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let e):
                    debugPrint("e \(e)")
                case .finished: break
                }
            }, receiveValue: { [weak self] response in
                self?.itemListSubject.send(response.data)
                self?.updatePagnationSubject.send(response.pagination)
            })
            .store(in: &subscriptions)
    }
    
    private func requestFavorite() {
        do {
            let entities = try itemCacheService.fetchItems()
            let items = entities
                    .map({FavoriteItem.init(itemEntity: $0)})
                    .sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
            itemListSubject.send(items)
            updatePagnationSubject.send(nil)
        } catch let error {
            debugPrint("e \(error)")
        }
    }
}

extension ViewModel {
    func didTapFavorite(at data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws {
        try itemCacheService.handle(data: data, completion: completion)
    }
    
    func isFavorite(malID: Int) -> Bool {
        itemCacheService.isFavorite(malID: malID)
    }
}
