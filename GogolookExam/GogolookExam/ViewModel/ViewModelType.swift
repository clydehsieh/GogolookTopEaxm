//
//  ViewModelType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

protocol ViewModelType {
    func binding(fetchAnime: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error>
    func binding(fetchManga: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error>
    func binding(fetchFavorite: AnyPublisher<Void, Error>) -> AnyPublisher<[FavoriteItem], Error>
}
