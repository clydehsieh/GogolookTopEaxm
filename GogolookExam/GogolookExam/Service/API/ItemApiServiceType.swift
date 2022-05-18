//
//  ItemApiServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/18.
//

import UIKit
import Combine

protocol ItemApiServiceType {
    func fetchTopAnime(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error>
    func fetchTopManga(param: ItemRequestType) -> AnyPublisher<MangaTopResponse, Error>
}
