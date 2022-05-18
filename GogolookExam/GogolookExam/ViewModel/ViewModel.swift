//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class ViewModel {
    let service: ItemApiServiceType
    let itemCacheService: FavoriteItemCacheServiceType
    
    init(service: ItemApiServiceType, itemCacheService: FavoriteItemCacheServiceType) {
        self.service = service
        self.itemCacheService = itemCacheService
    }
}

extension ViewModel: ViewModelType {
    func binding(fetchAnime: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTopAnime(param: param)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchManga: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error> {
        fetchManga
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTopManga(param: param)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchFavorite: AnyPublisher<Void, Error>) -> AnyPublisher<[FavoriteItem], Error> {
        fetchFavorite
            .flatMapLatest { [unowned self] in
                Deferred {
                    Future { promise in
                        do {
                            let items = try itemCacheService.fetchItems()
                            promise(.success(
                                items
                                    .map({FavoriteItem.init(itemEntity: $0)})
                                    .sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
                            ))
                        } catch let e {
                            promise(.failure(e))
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func didTapFavorite(at data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws {
        try itemCacheService.handle(data: data, completion: completion)
    }
    
    func isFavorite(malID: Int) -> Bool {
        itemCacheService.isFavorite(malID: malID)
    }
}
