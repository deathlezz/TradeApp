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
        
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-186400), kind: .text("Hello World")))
        
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("How is it going?")))
        
        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-60000), kind: .text("Here is a long reply. Here is a long reply. Here is a long reply.")))
        
        messages.append(Message(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-50000), kind: .text("Look it works")))
        
        messages.append(Message(sender: currentUser, messageId: "5", sentDate: Date().addingTimeInterval(-40000), kind: .text("I love making apps. I love making apps. I love making apps.")))
        
        messages.append(Message(sender: otherUser, messageId: "6", sentDate: Date().addingTimeInterval(-20000), kind: .text("And this is the last message")))
        
        setLayout()

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
    
    // set message background color
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemBlue : UIColor.systemGray5
    }
    
    // set avatars hidden
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        return avatarView.isHidden = true
    }
    
    // set bottom label as date
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // set top label height
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    // set bottom label height
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    // set messages layout
    func setLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
        }
    }
    
    
    
}
