//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class ViewModel {
    let service: AnimeApiServiceType
    init(service: AnimeApiServiceType) {
        self.service = service
    }
}

extension ViewModel: ViewModelType {
    func binding(fetchAnime: AnyPublisher<AnimeTopRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTop(param: param)
            })
            .eraseToAnyPublisher()
    }
}


//MARK: -
protocol MangaViewModelType {
    func binding(fetchManga: AnyPublisher<MangaTopRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error>
}

class MangaViewModel {
    let service: MangaApiServiceType
    init(service: MangaApiServiceType) {
        self.service = service
    }
}

extension MangaViewModel: MangaViewModelType {
    func binding(fetchManga: AnyPublisher<MangaTopRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error> {
        fetchManga
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTop(param: param)
            })
            .eraseToAnyPublisher()
    }
}
