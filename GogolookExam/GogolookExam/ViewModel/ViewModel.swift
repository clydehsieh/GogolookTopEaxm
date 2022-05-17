//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class ViewModel {
    let service: ItemApiService
    let coreDataStore: CoreDataStore
    
    init(service: ItemApiService, coreDataStore: CoreDataStore) {
        self.service = service
        self.coreDataStore = coreDataStore
    }
}

extension ViewModel: ViewModelType {
    func binding(fetchAnime: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTop(param: param)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchManga: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error> {
        fetchManga
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTop(param: param)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchFavorite: AnyPublisher<Void, Error>) -> AnyPublisher<[FavoriteItem], Error> {
        fetchFavorite
            .flatMapLatest { [unowned self] in
                Deferred {
                    Future { promise in
                        do {
                            let items = try self.coreDataStore.fetchItems()
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
}
