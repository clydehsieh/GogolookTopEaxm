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
        
        v.setup(filterTitle: "")
        v.setup(typeTitle: "")
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
    
    weak var coordinator: MainCoordinator?
    
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
        
        
        vm.requestNextPageEvent.send(())
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
        
        vm.updateItemListSubject
            .receive(on: DispatchQueue.main)
            .sink { items in
                weakSelf?.datasource = items
                debugPrint("datasource: \(weakSelf?.datasource.count ?? 0)")
            }
            .store(in: &subscriptions)
        
        
        vm.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    HUD.show(.progress)
                } else {
                    HUD.hide()
                }
            }
            .store(in: &self.subscriptions)
        
        vm.changeListTypeEvent
            .removeDuplicates()
            .sink { [weak self] listType in
                self?.cleanOptionsSelectViewHolder()
                self?.optionSegmentView.isUserInteractionEnabled = listType.enableSeletOptionSegmentView
            }
            .store(in: &subscriptions)
        
        vm.changeParamTypeEvent
            .removeDuplicates()
            .sink { [weak self] newType in
                self?.optionSegmentView.setup(typeTitle: newType ?? "")
            }
            .store(in: &subscriptions)
        
        vm.changeParamFilterEvent
            .removeDuplicates()
            .sink { [weak self] newFilter in
                self?.optionSegmentView.setup(filterTitle: newFilter ?? "")
            }
            .store(in: &subscriptions)
        
    }
}

//MARK: - data mutating
extension ItemListViewController {
    func changeListType(newType: ItemListType) {
        vm.changeListTypeEvent.send(newType)
        optionSegmentView.resetTitle()
    }
    
    func deleteDatasourceIfNeed(at row: Int) {
        guard vm.requestCache.listType.deleteDataWhenUnfavorite else {
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
        showOptionList(titles: vm.requestCache.listType.optionFilters, completion: { [weak self] indexPath, newFilter in
            self?.vm.changeParamFilterEvent.send(newFilter)
            self?.cleanOptionsSelectViewHolder()
        })
    }
    
    func didTapType() {
        showOptionList(titles: vm.requestCache.listType.optionTypes, completion: { [weak self] indexPath, newType in
            self?.vm.changeParamTypeEvent.send(newType)
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
        guard indexPath.row > ( datasource.count - 5) else { return }
        vm.requestNextPageEvent.send(())
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
