//
//  LogInViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import Kingfisher
import FirebaseAuth
import JGProgressHUD
class LogInViewController: UIViewController {

    private let spinner = JGProgressHUD(style:.dark)
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var btnFacebook:  FBSDKLoginButton!
   
    let userDefualt = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

//        btnFacebook.permissions = ["public_profile", "email"]
    }

    override func viewWillAppear(_ animated: Bool) {
        loginUser()
        
        imageView.kf.setImage(with:URL(string:"https://download.logo.wine/logo/Facebook_Messenger/Facebook_Messenger-Logo.wine.png"))
        
      
        
    }
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        loginUser()
//            let ConverVC = storyboard?.instantiateViewController(withIdentifier: String(describing: ConversationViewController.self)) as! ConversationViewController
//            self.navigationController?.pushViewController(ConverVC, animated: true)
        
    }
   
    
    func loginUser(){
        
        spinner.show(in: view)
        if let email = email.text,
           let pass = password.text {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass, completion: { authResult, error in
            
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            let user = result.user
            let ConverVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ConversationViewController.self)) as! ConversationViewController
            self.navigationController?.pushViewController(ConverVC, animated: true)
        })
        }
    }
    @IBAction func RegisterBtnPressed(_ sender: UIBarButtonItem) {
        let RegisterVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RegisterViewController.self)) as! RegisterViewController
        self.navigationController?.pushViewController(RegisterVC, animated: true)
    }
}
