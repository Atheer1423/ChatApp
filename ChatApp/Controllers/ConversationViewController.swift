//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationViewController: UIViewController {
    
   
    
    private let spinner = JGProgressHUD(style: .dark)
        
        private let tableView: UITableView = {
            let table = UITableView()
            table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
            
            table.register(UITableViewCell.self, forCellReuseIdentifier: "Convercell")
            return table
        }()
        
        private let noConversationsLabel: UILabel = {
            let label = UILabel()
            label.text = "No conversations"
            label.textAlignment = .center
            label.textColor = .gray
            label.isHidden = true
            label.font = .systemFont(ofSize: 21, weight: .medium)
            return label
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose , target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        fetchConversations()
    }
    
    @objc private func didTapComposeButton(){
           // present new conversation view controller
           // present in a nav controller
        let vc = NewConversationViewController()
        vc.completion = { [weak self]
            result in
//            print ("\(result)")
            self?.createNewConversation(result: result)
        }
               let navVC = UINavigationController(rootViewController: vc)
               present(navVC,animated: true)
       }
    
    private func createNewConversation(result:[String:String]){
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let ChatVC = ChatViewController(with:email)
        ChatVC.isNewConversation = true
        ChatVC.title =  name
        ChatVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(ChatVC, animated: true)

    }
    
    private func fetchConversations(){
            // fetch from firebase and either show table or label

            tableView.isHidden = false
        }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           tableView.frame = view.bounds

       }
    
    override func viewDidAppear(_ animated: Bool) {
       
//     if let token = AccessToken.current, !token.isExpired { // User is logged in
//         let ConverVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ConversationViewController.self)) as! ConversationViewController
//         self.navigationController?.pushViewController(ConverVC, animated: true)
//     }
        validateAuth()
     
    }
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // present login view controller
//            let loginVC = LogInViewController()
//            let nav = UINavigationController(rootViewController: loginVC)
//            nav.modalPresentationStyle = .fullScreen
//            present(nav,animated: true)

            let loginVC =   storyboard?.instantiateViewController(withIdentifier: String(describing: LogInViewController.self)) as! LogInViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
}
    extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Convercell", for: indexPath)
            cell.textLabel?.text = "Hello World"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        // when user taps on a cell, we want to push the chat screen onto the stack
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            let ChatVC = ChatViewController(with: "ath@gmail.com")
            ChatVC.title =  "Atheer"
            ChatVC.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(ChatVC, animated: true)
        }
    }


