//
//  ApiServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

protocol AnimeTopRequestType {
    var type: AnmineType { get }
    var filter: AnmineFilter { get }
    var page: Int { get }
}

protocol ApiServiceType {
    func fetchTopAnimne(param: AnimeTopRequestType) -> AnyPublisher<AnimeTopResponse, Error>
}
