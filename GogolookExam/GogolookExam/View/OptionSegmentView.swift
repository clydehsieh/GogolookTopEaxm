//
//  OptionSegmentView.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

import UIKit
import SnapKit

struct OptionSegmentViewConfig {
    static let height = 30
}

typealias OptionTypeData = [RequestTypePresentable]
typealias OptionFilterData = [RequestFilterPresentable]
typealias OptionData = (types: OptionTypeData, filters: OptionFilterData)

class OptionSegmentView: UIView {
    typealias TapButtonHandler = (() -> Void)
    let typeButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        btn.contentEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        return btn
    }()
    
    let filterButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        btn.contentEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        return btn
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [typeButton, filterButton])
        sv.spacing = 5
        return sv
    }()
    
    var datasource: OptionData = ([], [])
    var tapTypeButtonHandler: TapButtonHandler?
    var tapFilterButtonHandler: TapButtonHandler?
    
    init(tapTypeHandler: @escaping TapButtonHandler, typeFilterHandler: @escaping TapButtonHandler) {
        self.tapTypeButtonHandler = tapTypeHandler
        self.tapFilterButtonHandler = typeFilterHandler
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewHierarchyNotReady = true
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard viewHierarchyNotReady else { return }
        constructViewHierarchy()
        activateConstraints()
        configureButtons()
        viewHierarchyNotReady = false
    }
    
    func setup(typeTitle: String, filterTitle: String) {
        typeButton.setTitle(" ▾ Type: \(typeTitle)", for: .normal)
        filterButton.setTitle(" ▾ Filter : \(filterTitle)", for: .normal)
    }
}

extension OptionSegmentView {
    private func constructViewHierarchy() {
        addSubview(stackView)
    }
    
    private func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    
    private func configureButtons() {
        typeButton.addTarget(self, action: #selector(didTapTypeButton), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(didFilterTypeButton), for: .touchUpInside)
    }
}

//MARK: - actions
extension OptionSegmentView {
    @objc func didTapTypeButton() {
        tapTypeButtonHandler?()
    }
    
    @objc func didFilterTypeButton() {
        tapFilterButtonHandler?()
    }
}
