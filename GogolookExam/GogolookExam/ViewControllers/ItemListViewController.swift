//
//  ItemListViewController.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit
import Combine
import PKHUD

class ItemListViewController: UIViewController {
    
    //MARK: - views
    lazy var segmentView: SegmentView = {
        let v = SegmentView { [weak self] type in
            self?.changeListType(newType: type)
        }
        return v
    }()
    
    lazy var optionSegmentView: OptionSegmentView = {
        let v = OptionSegmentView { [weak self] in
            self?.didTapType()
        } typeFilterHandler: { [weak self] in
            self?.didTapFilter()
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
    
    var optionsSelectViewHolder: OptionsSelectView?
    
    //MARK: DI
    let vm: ViewModelType
    
    //MARK:
    var subscriptions: Set<AnyCancellable> = .init()
    var itemRequestState = ItemRequestState.init()
    let animeTopRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    let mangaTopRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    let favoriteTopRequest: PassthroughSubject<Void, Error> = .init()
    
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    
    weak var coordinator: MainCoordinator?
    var needResetFlag = false
    var currentListType: ItemListType = .anime
    
    //MARK: - lifecycle
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
        
        self.fetchItem(type: nil, filter: nil, page: ItemRequestState.beginPage)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanOptionsSelectViewHolder()
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
            make.top.equalTo(segmentView.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(30)
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
        
        isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    HUD.show(.progress)
                } else {
                    HUD.hide()
                }
            }
            .store(in: &self.subscriptions)
        
        vm.binding(fetchAnime: animeTopRequest.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
                weakSelf?.isLoading.send(false)
            } receiveValue: { response in
                weakSelf?.itemRequestState.currentPage = response.pagination.currentPage
                weakSelf?.itemRequestState.hasNextPage = response.pagination.hasNextPage
                weakSelf?.addNewItem(response.data)
                weakSelf?.isLoading.send(false)
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
                weakSelf?.isLoading.send(false)
            } receiveValue: { response in
                weakSelf?.itemRequestState.currentPage = response.pagination.currentPage
                weakSelf?.itemRequestState.hasNextPage = response.pagination.hasNextPage
                weakSelf?.addNewItem(response.data)
                weakSelf?.isLoading.send(false)
            }
            .store(in: &self.subscriptions)
        
        vm.binding(fetchFavorite: favoriteTopRequest.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case let .failure(e):
                    debugPrint(e)
                }
                weakSelf?.isLoading.send(false)
            } receiveValue: { data in
                weakSelf?.itemRequestState.currentPage = 1
                weakSelf?.itemRequestState.hasNextPage = false
                weakSelf?.addNewItem(data)
                weakSelf?.isLoading.send(false)
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
        
        itemRequestState.type = nil
        itemRequestState.filter = nil
        cleanOptionsSelectViewHolder()
        
        //
        optionSegmentView.isUserInteractionEnabled = newType.enableSeletOptionSegmentView
        
        reloadByCurrentState()
    }
    
    func reloadByCurrentState() {
        needResetFlag = true
        self.fetchItem(type: itemRequestState.type,
                       filter: itemRequestState.filter,
                       page: ItemRequestState.beginPage)
    }
    
    func fetchItem(type: String?, filter: String?, page: Int) {
        
        guard isLoading.value == false else {
            return
        }
        
        itemRequestState.filter = filter
        itemRequestState.type = type
        
        // update filter display
        optionSegmentView.setup(typeTitle: type ?? "",
                                filterTitle: filter ?? "")
        
        isLoading.send(true)
        
        // reqest
        switch currentListType {
        case .anime:
            animeTopRequest.send(ItemRequest(
                type: type,
                filter: filter,
                page: max(ItemRequestState.beginPage, page))
            )
        case .manga:
            mangaTopRequest.send(ItemRequest(
                type: type,
                filter: filter,
                page: max(ItemRequestState.beginPage, page))
            )
        case .favorite:
            favoriteTopRequest.send(())
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
    
    func deleteDatasourceIfNeed(at row: Int) {
        guard currentListType.deleteDataWhenUnfavorite else {
            return
        }
        
        guard row < datasource.count else {
            return
        }
        
        datasource.remove(at: row)
    }
}

//MARK: - Actions
extension ItemListViewController {
    func cleanOptionsSelectViewHolder() {
        optionsSelectViewHolder?.removeFromSuperview()
        optionsSelectViewHolder = nil
    }
    
    func didTapFilter() {
        showOptionList(titles: currentListType.optionFilters, completion: { [weak self] indexPath, newFilter in
            if self?.itemRequestState.filter != newFilter {
                self?.itemRequestState.filter = newFilter
                self?.reloadByCurrentState()
            }
            self?.cleanOptionsSelectViewHolder()
        })
    }
    
    func didTapType() {
        showOptionList(titles: currentListType.optionTypes, completion: { [weak self] indexPath, newType in
            if self?.itemRequestState.type != newType {
                self?.itemRequestState.type = newType
                self?.reloadByCurrentState()
            }
            self?.cleanOptionsSelectViewHolder()
        })
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
        cell.delegate = self
        
        cell.didChange(isFavorite: vm.isFavorite(malID: data.malID))
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let next = itemRequestState.nextPage, indexPath.row > ( datasource.count - 5) {
            fetchItem(type: itemRequestState.type, filter: itemRequestState.filter, page: next)
        }
    }
}

extension ItemListViewController {
    func showOptionList(titles: [OptionsSelectTableViewCellConfigurable],
                        completion: @escaping OptionsSelectView.SelectOptionHandler ) {
        self.cleanOptionsSelectViewHolder()
        
        let view = OptionsSelectView.init(titles: titles) { indexPath, title in
            completion(indexPath, title)
        }
        optionsSelectViewHolder = view
        
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(optionSegmentView.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(300)
        }
    }
}

//MARK: - ItemTableViewCellDelete
extension ItemListViewController: ItemTableViewCellDelete {
    func didTapFavoriteButton(cell: UITableViewCell) {
        guard let index = tableView.indexPath(for: cell) else {
            return
        }
        
        guard let data = datasource[safe: index.row] else {
            return
        }
        
        do {
            HUD.show(.progress)
            try vm.didTapFavorite(at: data) { [weak self] result in
                
                func updateState(isFavorite: Bool) {
                    if let cell = cell as? ItemFavorteStateObserable {
                        cell.didChange(isFavorite: isFavorite)
                    }
                }
                
                switch result {
                case .saved:
                    updateState(isFavorite: true)
                case .deleted:
                    updateState(isFavorite: false)
                    self?.deleteDatasourceIfNeed(at: index.row )
                case let .failure(error):
                    debugPrint("handle cache fail: \(error.localizedDescription)")
                }
                
                HUD.hide()
            }
        } catch let error {
            debugPrint("handle cache: \(error.localizedDescription)")
            HUD.hide()
        }
        
    }
    
}
