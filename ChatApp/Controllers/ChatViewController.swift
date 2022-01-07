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

struct Message : MessageType {
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
        messageInputBar.delegate = self
      


    }
    
    

    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           messageInputBar.inputTextView.becomeFirstResponder() // present keyboard
        if let ConversationId = conversationId {
            listenForMessages(id:ConversationId, shouldScrollToBottom : true)
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
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
  
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else{
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
        
        
    
  
