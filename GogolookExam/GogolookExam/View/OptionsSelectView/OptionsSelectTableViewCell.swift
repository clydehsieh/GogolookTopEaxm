//
//  OptionsSelectTableViewCell.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

protocol OptionsSelectTableViewCellConfigurable {
    var optionTitle: String { get } 
}

class OptionsSelectTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 14, weight: .bold)
        return lb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var viewHierarchyNotReady = true
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard viewHierarchyNotReady else { return }
        constructViewHierarchy()
        activateConstraints()
        selectionStyle = .none
        viewHierarchyNotReady = false
    }
    
    func setup(with configue: OptionsSelectTableViewCellConfigurable) {
        titleLabel.text = configue.optionTitle
    }
}


extension OptionsSelectTableViewCell {
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
