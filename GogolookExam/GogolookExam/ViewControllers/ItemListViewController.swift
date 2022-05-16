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
        let v = SegmentView { [weak self] type in
            self?.changeListType(newType: type)
        }
        return v
    }()
    
    lazy var optionSegmentView: OptionSegmentView = {
        let v = OptionSegmentView {
            debugPrint("tap type")
        } typeFilterHandler: {
            debugPrint("tap filter")
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
    let animeTopRequest: CurrentValueSubject<ItemRequestType, Error> = .init(ItemRequest.defaultConfig)
    let mangaTopRequest: CurrentValueSubject<ItemRequestType, Error> = .init(ItemRequest.defaultConfig)
    
    weak var coordinator: MainCoordinator?
    var needResetFlag = false
    var currentListType: ItemListType = .anime
    
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
        
        
        self.reqeust(type: nil, filter: nil, page: 0)
    }
}

//MARK: - config
extension ItemListViewController {
    private func constructViewHierarchy() {
        view.addSubview(segmentView)
        view.addSubview(optionSegmentView)
        view.addSubview(tableView)
    }
    
    private func activateConstraints() {
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(SegmentViewConfig.height)
        }
        
        optionSegmentView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(optionSegmentView.snp.bottom).offset(10)
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
        
        weak var weakSelf = self
        vm.binding(fetchAnime: animeTopRequest.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { response in
                debugPrint("Anime \(response.data.count)")
                weakSelf?.addNewItem(response.data)
            }
            .store(in: &self.subscriptions)
        
        
        vm.binding(fetchManga: mangaTopRequest.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
            } receiveValue: { response in
                debugPrint("Anime \(response.data.count)")
                weakSelf?.addNewItem(response.data)
            }
            .store(in: &self.subscriptions)
    }
}

//MARK: - data mutating
extension ItemListViewController {
    func changeListType(newType: ItemListType) {
        guard currentListType != newType else {
            return
        }
        
        currentListType = newType
        needResetFlag = true
        self.reqeust(type: nil, filter: nil, page: 0)
    }
    
    func reqeust(type: String?, filter: String?, page: Int) {
        
        // update filter display
        optionSegmentView.setup(typeTitle: type ?? "",
                                filterTitle: filter ?? "")
        
        // reqest
        switch currentListType {
        case .anime:
            animeTopRequest.send(ItemRequest(
                type: type,
                filter: filter,
                page: max(0, page))
            )
        case .manga:
            mangaTopRequest.send(ItemRequest(
                type: type,
                filter: filter,
                page: max(0, page))
            )
        }
    }
    
    func addNewItem(_ items: [ItemTableViewCellConfigurable]) {
        if needResetFlag {
            needResetFlag = false
            datasource = items
        } else {
            datasource.append(contentsOf: items)
        }
    }
}

//MARK: - UITableViewDataSource
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

//MARK: - UITableViewDelegate
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
