//
//  ItemListViewController.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit
import Combine

class ItemListViewController: UIViewController {

    //MARK: - views
    lazy var segmentView: SegmentView = {
        let v = SegmentView { type in
            debugPrint("tap \(type.rawValue)")
        }
        return v
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    var datasource: [ItemTableViewCellConfigurable] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: DI
    let vm: ViewModelType
    
    //MARK:
    var subscriptions: Set<AnyCancellable> = .init()
    let animeTopRequest: CurrentValueSubject<AnimeTopRequestType, Error> = .init(AnimeTopRequest.defaultConfige())
    
    weak var coordinator: MainCoordinator?
    
    init(vm: ViewModelType) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
        configureTableView()
        setupBinding()
        
        animeTopRequest.send(AnimeTopRequest.defaultConfige())
    }
}


extension ItemListViewController {
    private func constructViewHierarchy() {
        view.addSubview(segmentView)
        view.addSubview(tableView)
    }
    
    private func activateConstraints() {
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(SegmentViewConfig.height)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        tableView.estimatedRowHeight = 90
        tableView.register(cellClass: ItemTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupBinding() {
        vm.binding(fetchAnime: animeTopRequest.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { [weak self] response in
                debugPrint("Anime \(response.data.count)")
                self?.datasource.append(contentsOf: response.data)
            }
            .store(in: &self.subscriptions)
    }
}

extension ItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = datasource[safe: indexPath.row] else {
            fatalError()
        }
        let cell: ItemTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setup(with: data)
        return cell
    }
}

extension ItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = datasource[safe: indexPath.row] else {
            fatalError()
        }
        
        do {
            try coordinator?.openURL(url: data.videoURL)
        } catch let error {
            if let e = error as? FlowError, e == .invalidateURL {
                debugPrint("invalidateURL ")
            } else {
                debugPrint("unknow ")
            }
        }
    }
}
