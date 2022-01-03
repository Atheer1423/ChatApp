//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import JGProgressHUD
class NewConversationViewController: UIViewController {

    private  let spinner = JGProgressHUD()
    private let searchBar : UISearchBar = {
      let searchBar = UISearchBar()
        searchBar.placeholder = " Search for users.."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "newConverCell")
        table.backgroundColor = .white
        return table
    }()
    
    private let labelNoResults :UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
      
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel", style: .done , target:self , action : #selector(dismissSelf))
 
}
    @objc func dismissSelf()  {
          dismiss(animated: true, completion: nil)
      }
}
extension NewConversationViewController :UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
