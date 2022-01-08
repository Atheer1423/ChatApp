//
//  ChatViewController.swift
//  ChatApp
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import GoogleUtilities_UserDefaults
import Kingfisher
import AVFoundation
import AVKit
struct Message: MessageType {
   public var sender: SenderType
    
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind

}

struct Senderstruct : SenderType {
    public var senderId: String
    
    public var displayName: String
    
    public var photurl: String
    
}

struct Media : MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .long
           formatter.locale = .current
           return formatter
       }()
       
    public var isNewConversation = false
    public let otherUserEmail: String
    private let conversationId: String?
    private var messages : [Message] = []
    
    private var selfSender : Senderstruct? {
        guard let email =   UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        
   return Senderstruct(senderId:safeEmail ,displayName: "me", photurl: "")
        
    }
    
    private func listenForMessages(id:String,shouldScrollToBottom:Bool){
        DatabaseManger.shared.getAllMessagesForConversation(with: id, completion: { [weak self ] result in
            switch result {
            case .success(let message):
                guard  !message.isEmpty  else{
                    return
                }
                self?.messages = message
                
                DispatchQueue.main.async {
               
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with email: String, id:String?) {
        self.conversationId = id
           self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
      
           // creating a new conversation, there is no identifier

       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setUpIuputButton()


    }
    
   private func setUpIuputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName:"paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(actionSheet,animated:true)
    }
    
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "What would you like to attach photo from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
           let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker,animated:true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
             picker.sourceType = .photoLibrary
             picker.delegate = self
            picker.allowsEditing = true
             self?.present(picker,animated:true)
        }))
       actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
        present(actionSheet,animated:true)
    }
    
    private func presentVideoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach video", message: "What would you like to attach video from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
           let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker,animated:true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
             picker.sourceType = .photoLibrary
             picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium

            picker.allowsEditing = true
             self?.present(picker,animated:true)
        }))
       actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
        present(actionSheet,animated:true)
    }
    

    

    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           messageInputBar.inputTextView.becomeFirstResponder() // present keyboard
        if let ConversationId = conversationId {
            listenForMessages(id:ConversationId, shouldScrollToBottom : true)
        }
     
       }
    
 

}

extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    

  
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
      
            guard let messageId = createMessageId(),
                  let ConversationId = conversationId,
                  let name = self.title,
            let selfSender = selfSender else{
                return
            }
           if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
               let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "_") + ".png"
          // Uploadimage
           StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName ,completion: { [weak self] result in
               guard let strongSelf = self else {
                   return
               }
               switch result{
               case .success(let urlString):
                   // ready to send message
                   print("uploaded message photo: \(urlString)")
                   guard let url = URL(string: urlString),
                         let placeholder = UIImage(systemName:"plus") else{
                             return
                         }
                   let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                   let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                   DatabaseManger.shared.sendMessage(to: ConversationId, name: name, OtherUserEmail: strongSelf.otherUserEmail, newMessage: message, completion:{ success in
                       if success {
                           print("sent photo message")
                       }else{
                           print("failed to send photo message")
                       }
                       
                   } )
               case .failure(let error):
                  print("message photo upload error: \(error)")
               }
           })
       
           
       }

            else if let videoUrl = info[.mediaURL] as? URL {
                //upload video
               let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "_") + ".mov"
                StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName ,completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result{
                    case .success(let urlString):
                        // ready to send message
                        print("uploaded message Video: \(urlString)")
                        guard let url = URL(string: urlString),
                              let placeholder = UIImage(systemName:"plus") else{
                                  return
                              }
                        let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                        DatabaseManger.shared.sendMessage(to: ConversationId, name: name, OtherUserEmail: strongSelf.otherUserEmail, newMessage: message, completion:{ success in
                            if success {
                                print("sent photo message")
                            }else{
                                print("failed to send photo message")
                            }
                            
                        } )
                    case .failure(let error):
                       print("message photo upload error: \(error)")
                    }
                })
           }
}}
extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else{
            
            return
        }
        
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else{
                return
            }
            let vc = PhotoViewController(with:imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else{
                return
            }
           let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
            
        }
    }

}

extension ChatViewController :  MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let Sender = selfSender  {
            return Sender
        }
        fatalError("self sender is nil ,email should be cached")
    
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let mmessage = message as? Message else{
            return
        }
        switch mmessage.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.kf.setImage(with: imageUrl)
        default:
            break
        }
    }
    
 
}


extension ChatViewController: InputBarAccessoryViewDelegate {
    
  
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else
        {
            return
        }
    
        
        print("sending \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        // Send message
      
        if self.isNewConversation {
            //crete convo in db
            DatabaseManger.shared.createNewConversation(with: otherUserEmail,name:self.title ?? "User" , firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                }else{
                    print("failed to  sent")
                }
                
            })
          
        }else{
            // append to existing conversation data
            guard let ConversationId = conversationId, let name = self.title else {
               return
            }
            DatabaseManger.shared.sendMessage(to: ConversationId,name:name,OtherUserEmail:otherUserEmail, newMessage: message, completion: {success in
                if success {
                    print("message sent")
                }else{
                    print("failed to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt possibly
        // capital Self because its static
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String
      else {
            return nil
        }
        let safeCurentEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        
       
        let newIdentifier = " \(otherUserEmail)_\(safeCurentEmail)_\(dateString)"
print("created message id : \(newIdentifier)")
        
        return newIdentifier
        
    }






            
        }
        
        
    
  
