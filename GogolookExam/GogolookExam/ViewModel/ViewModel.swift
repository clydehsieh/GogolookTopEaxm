//
//  ViewModel.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class ViewModel {
    let service: ApiServiceType
    init(service: ApiServiceType) {
        self.service = service
    }
}

extension ViewModel: ViewModelType {
    func binding(fetchAnime: AnyPublisher<AnimeTopRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self] param in
                self.service.fetchTopAnimne(param: param)
            })
            .eraseToAnyPublisher()
    }
}
