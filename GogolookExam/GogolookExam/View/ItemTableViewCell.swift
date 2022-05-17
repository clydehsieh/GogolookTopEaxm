//
//  ItemTableViewCell.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit
import Kingfisher
import Combine
protocol ItemTableViewCellConfigurable {
    var malID: Int { get }
    var videoURL: URL? { get }
    var imageURL: URL? { get }
    var title: String? { get }
    var rank: Int? { get }
    var start: Date? { get }
    var end: Date? { get }
}

protocol ItemTableViewCellDelete: AnyObject {
    func didTapFavoriteButton(cell: UITableViewCell)
}

protocol ItemFavorteStateObserable {
    func didChange(isFavorite: Bool)
}

final class ItemTableViewCell: UITableViewCell {

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
    
    let likeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Fa", for: .normal)
        btn.setTitle("Un", for: .highlighted)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        return btn
    }()
    
    //MARK:
    var favoriteStateCancellable: AnyCancellable?
    weak var delegate: ItemTableViewCellDelete?
    
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
        selectionStyle = .none
        constructViewHierarchy()
        activateConstraints()
        configureButtons()
        viewHierarchyNotReady = false
    }
    
    func setup(with configue: ItemTableViewCellConfigurable) {
        coverImageView.kf.setImage(with: configue.imageURL)
        titleLabel.text = "\(configue.title ?? "")"
        rateLabel.text = "Rank: \(configue.rank ?? 0)"
        startDateLabel.text = "Start Date: \(configue.start?.dateTimeInStr ?? "")"
        endDateLabel.text = "End Date: \(configue.end?.dateTimeInStr ?? "")"
    }
}

extension ItemTableViewCell {
    private func constructViewHierarchy() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(likeButton)
    }
    
    private func activateConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(50)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
            make.size.equalTo(30)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(5)
            make.left.equalTo(coverImageView.snp.right).offset(5)
            make.right.equalTo(likeButton.snp.left).offset(5)
        }
    }
    
    private func configureButtons() {
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
    }
}

//MARK: - actions
extension ItemTableViewCell {
    @objc func didTapLikeButton() {
        delegate?.didTapFavoriteButton(cell: self)
    }
}
    

extension ItemTableViewCell: ItemFavorteStateObserable {
    func didChange(isFavorite: Bool) {
        let title = isFavorite ? "Y" : "N"
        likeButton.setTitle(title, for: .normal)
    }
}
