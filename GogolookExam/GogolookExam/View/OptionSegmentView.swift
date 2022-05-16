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

enum OptionSegmentViewType: String, CaseIterable {
    case type = "Type"
    case filter = "Filter"
}

class OptionSegmentView: UIView {
    typealias TapSegmentButtonHandler = ((OptionSegmentViewType) -> Void)
    
    let datasource: [OptionSegmentViewType]
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 5
        return sv
    }()
    
    var buttonCache: [UIButton: OptionSegmentViewType] = [:]
    var didTapButtonHandler: TapSegmentButtonHandler?
    
    init(datasource: [OptionSegmentViewType] = OptionSegmentViewType.allCases, tapHandler: @escaping TapSegmentButtonHandler) {
        self.datasource = datasource
        self.didTapButtonHandler = tapHandler
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
        buttonCache.removeAll()
        
        func createButton(title: String) -> UIButton {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 5
            btn.contentEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
            return btn
        }
        
        for type in datasource {
            let btn = createButton(title: type.rawValue)
            stackView.addArrangedSubview(btn)
            buttonCache[btn] = type
        }
    }
}

//MARK: - actions
extension OptionSegmentView {
    @objc func didTapButton(sender: UIButton) {
        guard let type = buttonCache[sender] else {
            return
        }
        didTapButtonHandler?(type)
    }
}
