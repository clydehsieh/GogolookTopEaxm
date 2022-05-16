//
//  ApiService.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class AnimeApiService {
    let decoder: JSONDecoder 
    var subscriptions: Set<AnyCancellable> = .init()
    
    init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }
}
 
extension AnimeApiService: AnimeApiServiceType {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error> {

        let url = URL(string: "https://api.jikan.moe/v4/top/anime?\(param.apiSuffixString())")!
        
        return Deferred {
            Future { promise in
                URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap() { element -> Data in
                        guard let httpResponse = element.response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                                  throw URLError(.badServerResponse)
                              }
                        return element.data
                    }
                    .decode(type: AnimeTopResponse.self, decoder: self.decoder)
                    .sink { completion in
                        switch completion {
                        case .finished: break
                        case let .failure(e):
                            promise(.failure(e))
                        }
                    } receiveValue: { response in
                        promise(.success(response))
                    }
                    .store(in: &self.subscriptions)
            }
        }.eraseToAnyPublisher()
    }
}
