//
//  ViewModelType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

protocol ViewModelType {
    func binding(fetchAnime: AnyPublisher<AnimeTopRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error>
}
