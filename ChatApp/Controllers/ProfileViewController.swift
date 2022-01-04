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
        tableViewOutlet.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader () -> UIView?{
        guard let email = UserDefaults.standard.value(forKey:"email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let filename = safeEmail + "_progile_pic.png"
        let path = "images/"+filename
        let Headerview = UIView(frame: CGRect(x: 0, y: 0, width: 400 ,height: 300))
        Headerview.backgroundColor = .link
        let imageprofile = UIImageView(frame: CGRect(x: (414-150)/2, y: 75, width: 150, height: 150 ))
        
        
        imageprofile.contentMode = .scaleToFill
        imageprofile.backgroundColor = .white
        imageprofile.layer.borderColor = UIColor.white.cgColor
        imageprofile.layer.borderWidth = 3
        imageprofile.layer.masksToBounds = true
        imageprofile.layer.cornerRadius = imageprofile.frame.width/2
        Headerview.addSubview(imageprofile)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageprofile, url: url)
            case .failure(let error):
                print(" failed to get download url: \(error)")
            }
        })
        
        return Headerview
    }
    
    func downloadImage (imageView:UIImageView, url:URL){
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data , error == nil else {
                return
            }
            DispatchQueue.main.async {
                
                let image = UIImage(data:data)
                imageView.image = image
            }
        }).resume()
        
        
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




