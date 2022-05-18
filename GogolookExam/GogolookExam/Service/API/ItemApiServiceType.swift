//
//  ItemApiServiceType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/18.
//

import UIKit
import Combine

protocol ItemApiServiceType {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error>
    func fetchTop(param: ItemRequestType) -> AnyPublisher<MangaTopResponse, Error>
}
