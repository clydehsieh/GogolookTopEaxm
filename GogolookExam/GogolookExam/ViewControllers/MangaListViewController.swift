//
//  MangaListViewController.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import Combine

class MangaListViewController: UIViewController {
    
    //MARK: DI
    let vm: MangaViewModelType
    
    //MARK:
    var subscriptions: Set<AnyCancellable> = .init()
    let animeTopRequest: CurrentValueSubject<MangaTopRequestType, Error> = .init(MangeTopRequest.defaultConfige())
    
    //MARK: - init
    init(vm: MangaViewModelType) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray
        title = "title"
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animeTopRequest.send(MangeTopRequest.defaultConfige())
    }
}

extension MangaListViewController {
    func setupBinding() {
        vm.binding(fetchManga: animeTopRequest.eraseToAnyPublisher())
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { response in
                debugPrint("manga \(response.data.count)")
            }
            .store(in: &self.subscriptions)
    }
}
