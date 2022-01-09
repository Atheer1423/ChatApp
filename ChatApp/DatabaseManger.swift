//
//  DatabaseManger.swift
//  ChatApp
//
//  Created by administrator on 03/01/2022.
//

import Foundation
import FirebaseDatabase
import MessageKit
import UIKit
final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    static func safeEmail (emailAddress:String)-> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
}
// MARK: - account management
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion : @escaping (Bool) -> Void){
        
        database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("faild to write to db")
                completion(false)
                return
            }
            
            // array of users - list of user to cha
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var userCollection = snapshot.value as? [[String:String]] {
                    // append to users
                    let newUser  =
                    [
                        "name": user.firstName + " "  + user.lastName,
                        "email": user.safeEmail
                    ]
                    
                    userCollection.append(newUser)
                    self.database.child("users").setValue(userCollection, withCompletionBlock: { error, _ in
                        guard  error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }else {
                    // create tha users - array -
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstName + " "  + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard  error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            }
            
        })
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String:String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
            
        })
        
        
    }
    
    public enum DatabaseError : Error {
        case failedToFetch
    }
    
}

extension DatabaseManger {
    public func getDataFor(path: String, completion : @escaping(Result<Any,Error>) -> Void ){
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: Sending messages / conversation
extension DatabaseManger {
    
    /*  "conversation_id" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     conversation => [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     
     ],
     
     ]
     
     */
    
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String,name:String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        // put conversation in the user's conversation collection, and then 2. once we create that new entry, create the root convo with all the messages in it
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                  return
              }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail) // cant have certain characters as keys
        
        // find the conversation collection for the given user (might not exist if user doesn't have any convos yet)
        
        let ref = database.child("\(safeEmail)")
        // use a ref so we can write to this as well
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            // what we care about is the conversation for this user
            guard var userNode = snapshot.value as? [String: Any] else {
                // we should have a user
                completion(false)
                print("user not found")
                return
            }
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String:Any] = [
                "id":conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            
            let recipient_newConversationData: [String:Any] = [
                "id":conversationId,
                "other_user_email": safeEmail, // my email
                "name":currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],  ]
            // update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversation = snapshot.value as? [[String:Any]] {
                    //append
                    conversation.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversationId])
                }else{
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            // update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exits for current user, you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation( name:name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
                
                
            }else{
                // conversation array does not exits,create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                    
                }
            }
            
        }
    }
    
    private func finishCreatingConversation( name:String, conversationID:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        //        {
        //            "id": String,
        //            "type": text, photo, video
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        //        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name" : name
            
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    /// Fetches and returns all conversations for the user with
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            
            let conversations : [Conversation] = value.compactMap({ dictionary in
                
                guard let conversationId = dictionary["id"] as? String
                        , let name = dictionary["name"] as? String,
                      let otherUserEmail =  dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                          return nil
                      }
                let latestMessageOBJ = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageOBJ)
            })
            completion(.success(conversations))
        })
    }
    
    /// gets all messages from a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages : [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let messageId =  dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String,
                      let dateString = ChatViewController.dateFormatter.date(from: date),
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let isRead = dictionary["is_read"] as? Bool else{
                          return nil
                          
                      }
                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string:content),
                          let placeholder = UIImage(systemName :"plus") else{
                              return nil
                          }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width:300,height:300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string:content),
                          let placeholder = UIImage(named :"video_placeholder") else{
                              return nil
                          }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width:300,height:300))
                    kind = .video(media)
                    
                }else{
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                let sender = Senderstruct(senderId: senderEmail, displayName: name, photurl: " ")
                return Message(sender: sender, messageId: messageId, sentDate: dateString, kind: finalKind)
                
            })
            completion(.success(messages))
        })
    }
    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String,name:String,OtherUserEmail:String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        //update sender latest message
        //update recipient latest message
        
        guard let myEmail = UserDefaults.standard.value(forKey:"email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self ]snapshot in
            guard let StrongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name" : name
                
            ]
            
            currentMessages.append(newMessageEntry)
            StrongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error,  _  in
                guard error == nil else {
                    completion(false)
                    return
                }
                StrongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String:Any]] else {
                        completion(false)
                        return
                    }
                    let updatedValue : [String:Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message":message
                    ]
                    var targetConversation : [String:Any]?
                    var position = 0
                    for Oneconversation in currentUserConversations {
                        if let currentId = Oneconversation["id"] as? String , currentId == conversation {
                            targetConversation = Oneconversation
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let TargetConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = TargetConversation
                    StrongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        // update latest  message for recipient user
                        StrongSelf.database.child("\(OtherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var  otherUserConversations = snapshot.value as? [[String:Any]] else {
                                completion(false)
                                return
                            }
                            let updatedValue : [String:Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message":message
                            ]
                            var targetConversation : [String:Any]?
                            var position = 0
                            for Oneconversation in otherUserConversations {
                                if let currentId = Oneconversation["id"] as? String , currentId == conversation {
                                    targetConversation = Oneconversation
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let TargetConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = TargetConversation
                            StrongSelf.database.child("\(OtherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                        
                    })
                })
                
            }
        })
        
    }
    public func deleteConversation(conversationId:String, completion : @escaping (Bool) -> Void){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        print("deleting conversation with id: \(conversationId)")
        // get all conversation for current user
        //delete conversation incollection with targetid
        // reset  those conversations for the user in db
        let ref =  database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var coversationsValue = snapshot.value as? [[String:Any]]{
                var positionToRemove = 0
                for conversationObj in coversationsValue {
                    if let id = conversationObj["id"] as? String,
                       id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                coversationsValue.remove(at: positionToRemove)
                ref.setValue(coversationsValue, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new converstion array")
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                })
            }
        }
    }
    
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    // create a computed property 
    var profilePictureFileName: String {
        return "\(safeEmail)_progile_pic.png"
    }
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

