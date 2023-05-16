//
//  ChatView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

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

class ChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var chatTitle: String!
    
    let currentUser = Sender(senderId: "self", displayName: "dzz")
    let otherUser = Sender(senderId: "other", displayName: "john smith")
    
    var messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = chatTitle

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        messagesCollectionView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        messages.append(Message(sender: currentUser, messageId: "0", sentDate: Date().addingTimeInterval(-186400), kind: .text("Hello World")))

        messages.append(Message(sender: otherUser, messageId: "1", sentDate: Date().addingTimeInterval(-70000), kind: .text("How is it going?")))

        messages.append(Message(sender: currentUser, messageId: "2", sentDate: Date().addingTimeInterval(-60000), kind: .text("Here is a long reply. Here is a long reply. Here is a long reply.")))

        messages.append(Message(sender: otherUser, messageId: "3", sentDate: Date().addingTimeInterval(-50000), kind: .text("Look it works")))

        messages.append(Message(sender: currentUser, messageId: "4", sentDate: Date().addingTimeInterval(-40000), kind: .text("I love making apps. I love making apps. I love making apps.")))

        messages.append(Message(sender: otherUser, messageId: "5", sentDate: Date().addingTimeInterval(-20000), kind: .text("And this is the last message")))
        
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
    
    // set "send" button
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print(text)
        messages.append(Message(sender: currentUser, messageId: "\(messages.count)", sentDate: Date(), kind: .text(text)))
        
        var indexPath = IndexPath()
        
        if messages.count > 0 {
            indexPath = IndexPath(index: messages.count - 1)
        } else {
            indexPath = IndexPath(index: 0)
        }
        
        messagesCollectionView.insertItems(at: [indexPath])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }
    
    // set bottom label as date
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let string = NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        return string
    }
    
    // set top label height
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    // set bottom label height
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    // set up messages layout
    func setLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingCellBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            layout.textMessageSizeCalculator.incomingCellBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
        }
    }
    
    // scroll view to last sent message
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            messagesCollectionView.contentInset = .zero
        } else {
            messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        messagesCollectionView.scrollIndicatorInsets = messagesCollectionView.contentInset
        messagesCollectionView.scrollToLastItem()
    }
    
    // hide keyboard on tap
    @objc func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
}