//
//  OptionsSelectView.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit
import SnapKit

class OptionsSelectView: UIView {
    typealias SelectOptionHandler = (IndexPath, String) -> Void
    
    let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .black.withAlphaComponent(0.3)
        return v
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    var selectOptionHandler: SelectOptionHandler?
    
    var datasource: [OptionsSelectTableViewCellConfigurable] = []
    
    var viewHierarchyNotReady = true
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard viewHierarchyNotReady else { return }
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        constructViewHierarchy()
        activateConstraints()
        configureTableView()
        viewHierarchyNotReady = false
    }
    
    init(titles: [OptionsSelectTableViewCellConfigurable], completion: @escaping SelectOptionHandler) {
        self.datasource = titles
        self.selectOptionHandler = completion
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - configure
extension OptionsSelectView {
    private func constructViewHierarchy() {
        addSubview(tableView)
    }
    
    private func activateConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        tableView.rowHeight = 30
        tableView.separatorStyle = .none
        tableView.register(cellClass: OptionsSelectTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

//MARK: - UITableViewDataSource
extension OptionsSelectView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = datasource[safe: indexPath.row] else {
            fatalError()
        }
        
        let cell: OptionsSelectTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setup(with: data)
        return cell
    }
}

extension OptionsSelectView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = datasource[safe: indexPath.row] else {
            fatalError()
        }
        
        self.selectOptionHandler?(indexPath, data.optionTitle)
    }
}
