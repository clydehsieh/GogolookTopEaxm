//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

final class ViewModel: ViewModelType {
    let itemCacheService: FavoriteItemCacheServiceType
    var subscriptions: Set<AnyCancellable> = .init()
    
    let networkManager: NetworkManager
    
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    
    var requestItemEventSubject: CurrentValueSubject<RequestType?, Never> = .init(nil)
    
    var updateItemListSubject: CurrentValueSubject<UpdateType, Never> = .init(.new(items: []))
    var updatePagnationSubject: CurrentValueSubject<Pagination?, Never> = .init(nil)
    
    var itemListSubject: CurrentValueSubject<[ItemTableViewCellConfigurable], Never> = .init([])
    
    var listTypeIsChanging = false
    var paramTypeIsChanging = false
    var paramFilterIsChanging = false

    var currentListType: CurrentValueSubject<ItemListType, Never> = .init(.anime)
    var currentParamType: CurrentValueSubject<String?, Never> = .init(nil)
    var currentParamFilter: CurrentValueSubject<String?, Never> = .init(nil)
    var currentPage: CurrentValueSubject<Int, Never> = .init(0)
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
                
                debugPrint("type did change to \(type)")
                self?.listTypeIsChanging = true
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
                debugPrint("param type did change to \(type ?? "nil")")
                guard let self = self, !self.listTypeIsChanging else { return }
                self.paramTypeIsChanging = true
                self.currentPage.send(1)
                self.request()
            }
            .store(in: &subscriptions)
        
        currentParamFilter
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] filter in
                debugPrint("param filter did change to \(filter ?? "nil")")
                guard let self = self, !self.listTypeIsChanging else { return }
                self.paramFilterIsChanging = true
                self.currentPage.send(1)
                self.request()
            }
            .store(in: &subscriptions)
        
        currentPage
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] page in
                debugPrint("param page did change to \(page)")
                guard let self = self, !self.listTypeIsChanging, !self.paramTypeIsChanging, !self.paramFilterIsChanging else { return }
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
                if self.listTypeIsChanging || self.paramTypeIsChanging || self.paramFilterIsChanging {
                    self.listTypeIsChanging = false
                    self.paramTypeIsChanging = false
                    self.paramFilterIsChanging = false
                    self.updateItemListSubject.send(.new(items: items))
                } else {
                    self.updateItemListSubject.send(.append(items: items))
                }
                self.isLoading.send(false)
            }
            .store(in: &subscriptions)
    }
}

extension ViewModel {
    func request() {
        guard !isLoading.value else { return }
        isLoading.send(true)
        
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
