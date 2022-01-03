//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by admin on 30/12/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {
    private let spinner = JGProgressHUD(style:.dark)
    @IBOutlet weak var passOutlet: UITextField!
    @IBOutlet weak var EmailOutlet: UITextField!
    @IBOutlet weak var LName: UITextField!
    @IBOutlet weak var FName: UITextField!
    @IBOutlet weak var imageOutlet: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

      
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
      
    }
    @IBAction func RegisterButnPressed(_ sender: UIButton) {
        if let email = EmailOutlet.text {
            spinner.show(in: view)
        DatabaseManger.shared.userExists(with:email) { isExist in
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
            if isExist {
                print(" email exsist")
                return
            }else{
                self.RegisterUser()
               
              
                
            }
        }
            
        }
       
    }
    
    @IBAction func TakeImageBtnPressed(_ sender: UIButton) {
        presentPhotoActionSheet()
    }
    
    func  inserUserInDB() {
        if let fname = FName.text,
           let lname = LName.text,
           let email = EmailOutlet.text {
        let user = ChatAppUser(firstName: fname, lastName: lname, emailAddress: email)
            DatabaseManger.shared.insertUser(with: user)
            
        }
    }
    
    func RegisterUser(){
        if let email = EmailOutlet.text,
           let pass = passOutlet.text {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pass, completion: { authResult , error  in
            guard let result = authResult, error == nil else {
                print(error?.localizedDescription)
                return
            }
            self.inserUserInDB()
            let ConverVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ConversationViewController.self)) as! ConversationViewController
                     self.navigationController?.pushViewController(ConverVC, animated: true)
        })
    }
    }
}
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageOutlet.image = selectedImage
        self.imageOutlet.layer.borderColor = UIColor.white.cgColor
        self.imageOutlet.layer.borderWidth = 4
        self.imageOutlet.layer.masksToBounds = true
        self.imageOutlet.layer.cornerRadius = 30
        self.imageOutlet.layer.cornerRadius = imageOutlet.frame.size.width/4
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


