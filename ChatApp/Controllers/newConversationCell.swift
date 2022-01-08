//
//  newConversationCell.swift
//  ChatApp
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import Kingfisher
import UIKit

class newConversationCell: UITableViewCell {
    
     static let identifier = "newConversationCell"
     private let userImageView: UIImageView = {
         let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.layer.cornerRadius = 35
         imageView.layer.masksToBounds = true
       return  imageView
     }()
     
     private let userNameLabel :UILabel = {
        let label = UILabel()
         label.font = .systemFont(ofSize: 19, weight: .semibold)
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
       
        userImageView.frame = CGRect(x:10 , y: 10, width: 70, height: 70)
        userNameLabel.frame = CGRect(x: 90,
                                     y: 20, width:( (contentView.frame.width - 20) - userImageView.frame.width) ,
                                     height: 50 )
    }

    public func configure(with model:SearchResult){
        self.userNameLabel.text = model.name
        let path = "images/\(model.email)_progile_pic.png"
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
    }}
 
