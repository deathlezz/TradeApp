//
//  ChatView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    let currentUser = Sender(senderId: "self", displayName: "dzz")
    let otherUser = Sender(senderId: "other", displayName: "john smith")
    
    var messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello World")))
        
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("How is it going?")))
        
        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-60000), kind: .text("Here is a long reply. Here is a long reply. Here is a long reply.")))
        
        messages.append(Message(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-50000), kind: .text("Look it works")))
        
        messages.append(Message(sender: currentUser, messageId: "5", sentDate: Date().addingTimeInterval(-40000), kind: .text("I love making apps. I love making apps. I love making apps.")))
        
        messages.append(Message(sender: otherUser, messageId: "6", sentDate: Date().addingTimeInterval(-20000), kind: .text("And this is the last message")))

    }
    
    // return current sender
    func currentSender() -> SenderType {
        return currentUser
    }
    
    // set collection view cell
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    // set number of section
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
