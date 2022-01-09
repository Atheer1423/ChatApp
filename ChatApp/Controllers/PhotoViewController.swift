//
//  PhotoViewController.swift
//  ChatApp
//
//  Created by administrator on 08/01/2022.
//

import UIKit
import MessageKit
class PhotoViewController: UIViewController {
    
    private let url : URL
    
    init (with url:URL){
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "photo"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.kf.setImage(with:url)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
}
