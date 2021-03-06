//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by administrator on 05/01/2022.
//

import UIKit
import Kingfisher
class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return  imageView
    }()
    
    private let userNameLabel :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(userNameLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x:10 , y: 10, width: 70, height: 70)
        userNameLabel.frame = CGRect(x: 90,
                                     y: 10, width:( (contentView.frame.width - 20) - userImageView.frame.width) ,
                                     height: 50 )
        userMessageLabel.frame = CGRect(x: 90, y: userNameLabel.frame.maxY+1 , width:( (contentView.frame.width - 20) - userImageView.frame.width) , height: (20))
        
    }
    
    public func configure(with model:Conversation){
        
        self.userMessageLabel.text = model.latestMessage.text
        
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_progile_pic.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case.success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.kf.setImage(with: url)
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
        
    }
}
