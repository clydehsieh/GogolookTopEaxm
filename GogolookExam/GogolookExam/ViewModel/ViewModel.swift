//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

final class ViewModel: ViewModelType {
    // state
    var requestCache: ItemRequest = .defaultConfig
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    
    // output
    private var itemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> = .init([])
    var updateItemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> = .init([])
    
    // input
    var changeListTypeEvent: PassthroughSubject<ItemListType, Never> = .init()
    var changeParamTypeEvent: PassthroughSubject<String?, Never> = .init()
    var changeParamFilterEvent: PassthroughSubject<String?, Never> = .init()
    var requestNextPageEvent: PassthroughSubject<Void, Never> = .init()
    
    //MARK: DI
    let itemCacheService: FavoriteItemCacheServiceType
    let networkManager: NetworkManager
    
    //MARK:
    var subscriptions: Set<AnyCancellable> = .init()
    var changePageEvent: PassthroughSubject<Int, Never> = .init()
    var pagination: Pagination? = .defaultConfig
    
    init(networkManager: NetworkManager, itemCacheService: FavoriteItemCacheServiceType) {
        self.networkManager = networkManager
        self.itemCacheService = itemCacheService
        
        setupBinding()
    }
    
    private func setupBinding() {
        changeListTypeEvent
            .removeDuplicates()
            .sink { [weak self] listType in
                debugPrint("listType to \(listType), reset param type & filter to nil, page to 1")
                self?.request(for: .init(listType: listType, type: nil, filter: nil, page: 1))
            }
            .store(in: &subscriptions)
        
        changeParamTypeEvent
            .removeDuplicates()
            .sink { [weak self] newType in
                guard let self = self else { return }
                debugPrint("param type did change to \(newType ?? "nil")")
                
                self.request(for: .init(listType: self.requestCache.listType,
                                        type: newType,
                                        filter: self.requestCache.filter,
                                        page: 1))
            }
            .store(in: &subscriptions)
        
        changeParamFilterEvent
            .removeDuplicates()
            .sink { [weak self] newFilter in
                guard let self = self else { return }
                debugPrint("param filter did change to \(newFilter ?? "nil")")
                self.request(for: .init(listType: self.requestCache.listType,
                                        type: self.requestCache.type,
                                        filter: newFilter,
                                        page: 1))
            }
            .store(in: &subscriptions)
        
        changePageEvent
            .removeDuplicates()
            .sink { [weak self] newPage in
                guard let self = self else { return }
                debugPrint("param page did change to \(newPage)")
                self.request(for: .init(listType: self.requestCache.listType,
                                        type: self.requestCache.type,
                                        filter: self.requestCache.filter,
                                        page: newPage))
            }
            .store(in: &subscriptions)
        
        itemListSubject
            .sink { [weak self] items in
                guard let self = self else { return }
                if self.requestCache.page == 1 {
                    self.updateItemListSubject.send(items)
                } else {
                    self.updateItemListSubject.value.append(contentsOf: items)
                }
                self.isLoading.send(false)
            }
            .store(in: &subscriptions)
        
        requestNextPageEvent
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard self.pagination?.hasNextPage ?? false else { return }
                guard self.requestCache.listType.isPageable else { return }
                guard !self.isLoading.value else { return }
                let nextPage = max(1, (self.requestCache.page + 1))
                self.changePageEvent.send(nextPage)
            }
            .store(in: &subscriptions)
    }
}

extension ViewModel {
    func request(for param: ItemRequest) {
        guard !isLoading.value else { return }
        isLoading.send(true
        )
        self.requestCache = param
        
        switch param.listType {
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
                self?.pagination = response.pagination
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
                self?.pagination = response.pagination
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
            pagination = nil
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
