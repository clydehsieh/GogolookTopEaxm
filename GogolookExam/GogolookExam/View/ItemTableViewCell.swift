//
//  ItemTableViewCell.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit
import Kingfisher

protocol ItemTableViewCellConfigurable {
    var videoURL: URL? { get }
    var imageURL: URL? { get }
    var title: String? { get }
    var rate: String? { get }
    var start: String? { get }
    var end: String? { get }
}

class ItemTableViewCell: UITableViewCell {

    let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 5
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 14, weight: .bold)
        return lb
    }()
    
    let rateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 10, weight: .regular)
        return lb
    }()
    
    let startDateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lightGray
        lb.font = .systemFont(ofSize: 10, weight: .regular)
        return lb
    }()
    
    let endDateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lightGray
        lb.font = .systemFont(ofSize: 10, weight: .regular)
        return lb
    }()
    
    lazy var labelStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, rateLabel, startDateLabel, endDateLabel])
        sv.axis = .vertical
        sv.spacing = 5
        return sv
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
    
    func setup(with configue: ItemTableViewCellConfigurable) {
        coverImageView.kf.setImage(with: configue.imageURL)
        titleLabel.text = "\(configue.title ?? "")"
        rateLabel.text = "Rate: \(configue.rate ?? "")"
        startDateLabel.text = "Start Date: \(configue.start ?? "")"
        endDateLabel.text = "End Date: \(configue.end ?? "")"
    }
}

extension ItemTableViewCell {
    private func constructViewHierarchy() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(labelStackView)
    }
    
    private func activateConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(50)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(5)
            make.left.equalTo(coverImageView.snp.right).offset(5)
            make.right.equalToSuperview().offset(5)
        }
    }
}
