//
//  FriendTableViewCell.swift
//  Messenger
//
//  Created by Katharos on 04/01/2023.
//

import UIKit
import SDWebImage

class FriendTableViewCell: UITableViewCell {

    static let identifier = "FriendTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 15, y: 10, width: 70, height: 70)
        userNameLabel.frame = CGRect(x: userImageView.right + 15, y: 30, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20) / 2)
    }
    
    public func configure(with model: Conversation) {
        userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }

}
