//
//  NetworkManager.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/18.
//

import UIKit
import Combine

enum EndPoint {
    case anime(param: ItemRequestType)
    case manga(param: ItemRequestType)
    
    var path: String {
        switch self {
        case let .anime(param):
            return "anime?\(param.apiSuffixString())"
        case let .manga(param):
            return "manga?\(param.apiSuffixString())"
        }
    }
}

class NetworkManager {
    static let share = NetworkManager()
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(OptionalFractionalSecondsDateFormatter())
        return decoder
    }()
    
    let baseURL = "https://api.jikan.moe/v4/top/"
    var subscription: Set<AnyCancellable> = .init()
    
    func request<T: Decodable>(endPoint: EndPoint, responseType: T.Type) -> AnyPublisher<T, Error> {
        Deferred {
            Future<T, Error> { [weak self] promise in
                guard let self = self, let url = self.baseURL.appending(endPoint.path).url else {
                    return promise(.failure(NetworkingError.invalidateURL))
                }
                
                URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap() { element -> Data in
                        guard let httpResponse = element.response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                                  throw URLError(.badServerResponse)
                              }
                        return element.data
                    }
                    .decode(type: T.self, decoder: self.decoder)
                    .sink { completion in
                        switch completion {
                        case .finished: break
                        case let .failure(e):
                            promise(.failure(e))
                        }
                    } receiveValue: { result in
                        promise(.success(result))
                    }
                    .store(in: &self.subscription)
            }
        }.eraseToAnyPublisher()
    }
}

enum NetworkingError: Error {
    case invalidateURL
}
