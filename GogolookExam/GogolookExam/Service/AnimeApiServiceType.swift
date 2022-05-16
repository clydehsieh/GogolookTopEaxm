//
//  ApiServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import Combine

protocol AnimeApiServiceType {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error>
}
