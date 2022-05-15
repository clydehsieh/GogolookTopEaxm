//
//  MangaApiServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import Combine

protocol MangaApiServiceType {
    func fetchTop(param: MangaTopRequestType) -> AnyPublisher<MangaTopResponse, Error>
}
