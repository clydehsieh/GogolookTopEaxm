//
//  ViewController.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class ViewController: UIViewController {

    //MARK: DI
    let vm: ViewModel
    
    //MARK:
    let service = ApiService()
    var subscriptions: Set<AnyCancellable> = .init()
    let animeTopRequest: CurrentValueSubject<AnimeTopRequestType, Error> = .init(AnimeTopRequest.defaultConfige())
    
    //MARK: - init
    init(vm: ViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupBinding()
        let rtype: AnimeTopRequestType = AnimeTopRequest(type: .tv, filter: .music, page: 0)
        request(param: rtype)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animeTopRequest.send(AnimeTopRequest.defaultConfige())
    }
}

extension ViewController {
    func setupBinding() {
        vm.binding(fetchAnime: animeTopRequest.eraseToAnyPublisher())
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { response in
                debugPrint(response.data.count)
            }
            .store(in: &self.subscriptions)
    }
    
    
    func request(param: AnimeTopRequestType) {
        let url = URL(string: "https://api.jikan.moe/v4/top/anime?type=\(param.type.rawValue)&filter=\(param.filter.rawValue)&page=\(param.page)")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return element.data
            }
            .decode(type: AnimeTopResponse.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { response in
                debugPrint(response.data.count)
            }
            .store(in: &self.subscriptions)
    }
}
