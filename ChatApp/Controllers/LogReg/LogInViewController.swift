//
//  LogInViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import Kingfisher
class LogInViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    let userDefualt = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }

    override func viewWillAppear(_ animated: Bool) {
   
        
        imageView.kf.setImage(with:URL(string:"https://download.logo.wine/logo/Facebook_Messenger/Facebook_Messenger-Logo.wine.png"))
        
      
        
    }
    @IBAction func logInBtnPressed(_ sender: UIButton) {
      
//            let ConverVC = storyboard?.instantiateViewController(withIdentifier: String(describing: ConversationViewController.self)) as! ConversationViewController
//            self.navigationController?.pushViewController(ConverVC, animated: true)
        
    }
    
    @IBAction func RegisterBtnPressed(_ sender: UIBarButtonItem) {
        let RegisterVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RegisterViewController.self)) as! RegisterViewController
        self.navigationController?.pushViewController(RegisterVC, animated: true)
    }
}
