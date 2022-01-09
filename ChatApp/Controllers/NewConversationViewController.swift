//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import JGProgressHUD
class NewConversationViewController: UIViewController {
    
    public var completion : ((SearchResult) -> Void)?
    private  let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String:String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = " Search for users.."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        //        table.isHidden = false
        table.register(newConversationCell.self, forCellReuseIdentifier: newConversationCell.identifier)
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
        view.addSubview(labelNoResults)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel", style: .done , target:self , action : #selector(dismissSelf))
        
        searchBar.resignFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        
        labelNoResults.frame = CGRect(x: view.frame.width/4, y: (view.frame.height-200)/2, width: (view.frame.width
                                                                                                  )/2, height: 200)
        
    }
    @objc func dismissSelf()  {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: newConversationCell.identifier, for:indexPath) as! newConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [ weak self] in
            self?.completion?(targetUserData)
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
}

extension NewConversationViewController :UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,!text.replacingOccurrences(of: " ", with: " ").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query:String){
        // check if array has firebase results
        if hasFetched {
            //filter
            filterUsers(term: query)
        }else{
            // fetch then filter
            DatabaseManger.shared.getAllUsers(completion: { [ weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(term: query)
                case .failure(let error):
                    print("failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers( term:String) {
        //update ui : show results or show - no resuls
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              hasFetched else {
                  return
              }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        self.spinner.dismiss()
        
        let results : [SearchResult] = self.users.filter({
            guard let email = $0["email"],email != safeEmail else {
                return false
            }
            guard let name = $0["name"]?.lowercased()  else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"] ,
                  let name = $0["name"]  else {
                      return nil
                  }
            return SearchResult(name: name, email: email)
            
        })
        self.results = results
        
        updateUI()
        
        
    }
    
    func updateUI (){
        if results.isEmpty {
            self.labelNoResults.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.labelNoResults.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name : String
    let email :String
}
