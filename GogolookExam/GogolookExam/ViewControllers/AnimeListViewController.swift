//
//  AnimeListViewController.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class AnimeListViewController: UIViewController {
    
    //MARK: DI
    let vm: ViewModelType
    
    //MARK:
    let service = ApiService()
    var subscriptions: Set<AnyCancellable> = .init()
    let animeTopRequest: CurrentValueSubject<AnimeTopRequestType, Error> = .init(AnimeTopRequest.defaultConfige())
    
    //MARK: - init
    init(vm: ViewModelType) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        title = "title"
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animeTopRequest.send(AnimeTopRequest.defaultConfige())
    }
}

extension AnimeListViewController {
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
}
