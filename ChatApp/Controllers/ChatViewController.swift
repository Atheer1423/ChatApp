//
//  ChatViewController.swift
//  ChatApp
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind

}

struct Senderstruct : SenderType {
    var senderId: String
    
    var displayName: String
    
    var photurl: String
    
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
//
//    public static var dateFormatter: DateFormatter = {
//           let formatter = DateFormatter()
//           formatter.dateStyle = .medium
//           formatter.timeStyle = .long
//           formatter.locale = .current
//           return formatter
//       }()
//
//    public let otherUserEmail: String
//       private let conversationId: String?
//       public var isNewConversation = false
//
    private var messages : [Message] = []
    private var sender = Senderstruct(senderId: "1", displayName: "sara", photurl: "")
//
//    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented"
//    }
//
//    init(with email: String, id: String?) {
//           self.conversationId = id
//           self.otherUserEmail = email
//        super.init(nibName: nil, bundle: nil)
//
//           // creating a new conversation, there is no identifier
//
//       }
//
//
//
//
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("hello")))
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("hi")))
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("how are you")))
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

    }
//
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           messageInputBar.inputTextView.becomeFirstResponder()

//           if let conversationId = conversationId {
//               listenForMessages(id:conversationId, shouldScrollToBottom: true)
//           }
       }
//
//
//    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
//
////            DatabaseManger.shared.getAllMessagesForConversation(with: id) { [weak self] result in
////                switch result {
////                case .success(let messages):
////                    print("success in getting messages: \(messages)")
////                    guard !messages.isEmpty else {
////                        print("messages are empty")
////                        return
////                    }
////                    self?.messages = messages
////
////                    DispatchQueue.main.async {
////                        self?.messagesCollectionView.reloadDataAndKeepOffset()
////
////                        if shouldScrollToBottom {
////                            self?.messagesCollectionView.scrollToLastItem()
////
////                        }
////
////                    }
////
////                case .failure(let error):
////                    print("failed to get messages: \(error)")
////                }
////            }
//
    

}
extension ChatViewController :  MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
//    if let sender = selfSender {
//
//    return sender
//       }
//       print("Self sender is nil, email should be cached")
        
//       return Senderstruct(photoURL: "", senderId: "12", displayName: "")

    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId()  else {
//            return
//        }
        
//        print("sending \(text)")
//
//        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
//
//        // Send message
//        if isNewConversation {
            // create convo in database
            // message ID should be a unique ID for the given message, unique for all the message
            // use random string or random number
//            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
//                if success {
//                    print("message sent")
//                    self?.isNewConversation = false
//                }else{
//                    print("failed to send")
//                }
//            }
//
//        }else {
//            guard let conversationId = conversationId, let name = self.title else {
//                return
//            }
            
            // append to existing conversation data
//            DatabaseManger.shared.sendMessage(to: conversationId, name: name, newMessage: message) { success in
//                if success {
//                    print("message sent")
//                }else {
//                    print("failed to send")
//                }
//            }
            
        }
        
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt possibly
        // capital Self because its static
    
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
//        let safeCurrentEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        
//        let dateString = Self.dateFormatter.string(from: Date())
//        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
    
//        print("created message id: \(newIdentifier)")
//        return newIdentifier
        return " "
        
    }



    

