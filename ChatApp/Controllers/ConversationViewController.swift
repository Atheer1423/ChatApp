//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation{
    let id : String
    let name : String
    let otherUserEmail: String
    let latestMessage:LatestMessage
}

struct LatestMessage {
    let date : String
    let text :String
    let isRead: Bool
}

class ConversationViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    private  var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier
        )
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
        tableView.frame = view.bounds
        
        fetchConversations()
        startListeningForConversation()
    }
    
    private func startListeningForConversation(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        
        print("starting conversation fetch..")
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        DatabaseManger.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            switch result {
            case .success(let conversationss):
                print("seccessfully got conversation models")
                guard !conversationss.isEmpty else {
                    return
                }
                
                self?.conversations = conversationss
                
                DispatchQueue.main.async {
                    print("reloa")
                    
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("coversations get convos : \(error)")
            }
        })
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
    
    private func createNewConversation(result:SearchResult){
        let name = result.name
        let email = result.email
        let ChatVC = ChatViewController(with:email, id:nil)
        ChatVC.isNewConversation = true
        ChatVC.title =  name
        ChatVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(ChatVC, animated: true)
        
    }
    
    private func fetchConversations(){
        tableView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.validateAuth()
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            //             present login view controller
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: LogInViewController.self)) as! LogInViewController
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC,animated: true)
            
        }
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        
        return cell
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let ChatVC = ChatViewController(with: model.otherUserEmail,id:model.id)
        ChatVC.title =  model.name
        ChatVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(ChatVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // handle delete action
        let conversationId = conversations[indexPath.row].id
        if editingStyle == .delete{
            tableView.beginUpdates()
            DatabaseManger.shared.deleteConversation(conversationId: conversationId, completion: { [weak self] success in
                if success {
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            })
            
            tableView.endUpdates()
        }
        
    }
}


