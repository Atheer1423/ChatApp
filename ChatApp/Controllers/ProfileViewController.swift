//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    var profileContent = ["Log out"]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewOutlet.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
    }
    


}
extension ProfileViewController : UITableViewDataSource, UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        cell.textLabel?.text = profileContent[indexPath.row]
        cell.textLabel?.textAlignment = .center
              cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
               
               actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                   // action that is fired once selected
                   
                   guard let strongSelf = self else {
                       return
                   }
                   do {
                       try FirebaseAuth.Auth.auth().signOut()
                       
                       // present login view controller
                       let loginVC = strongSelf.storyboard?.instantiateViewController(withIdentifier: String(describing: LogInViewController.self)) as! LogInViewController
                       strongSelf.navigationController?.pushViewController(loginVC, animated: true)
                   }
                   catch {
                       print("failed to logout")
                   }
                   
               }))
               
               actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               present(actionSheet, animated: true)
           }
    }
    
    


