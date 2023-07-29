//
//  ChatView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var chatTitle: String!
    var loggedUser: String!
    var itemID: Int!
    
    var buyer: String!
    var seller: String!
    
    var isPushedByChats: Bool!
    
    var reference: DatabaseReference!
    
    var messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = chatTitle
        navigationItem.largeTitleDisplayMode = .never

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setLayout()
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
    }
    
    // return current sender
    func currentSender() -> SenderType {
        return Sender(senderId: loggedUser, displayName: "")
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
        
        let currentBuyer = Sender(senderId: buyer, displayName: "")
//        let currentSeller = Sender(senderId: seller, displayName: "")
        
        let message = Message(sender: currentBuyer, messageId: "\(messages.count)", sentDate: Date(), kind: .text(text))
        messages.append(message)
        saveMessage(seller: seller, buyer: buyer, itemID: itemID, message: message)
        
        var indexPath = IndexPath()
        
        if messages.count > 0 {
            indexPath = IndexPath(index: messages.count - 1)
        } else {
            indexPath = IndexPath(index: 0)
        }
        
        messagesCollectionView.insertItems(at: [indexPath])
        inputBar.inputTextView.text = nil
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
    
    // set message bottom label as date
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let string = NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        return string
    }
    
    // set message bottom label height
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    // set up messages layout
    func setLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
        }
    }
    
    // scroll view to last sent message
    @objc func adjustForKeyboard(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + messageInputBar.frame.height - view.safeAreaInsets.bottom, right: 0)
        messagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
    
    // save message to Firebase Database
    func saveMessage(seller: String, buyer: String, itemID: Int, message: Message) {
        let fixedSeller = seller.replacingOccurrences(of: ".", with: "_")
        let fixedBuyer = buyer.replacingOccurrences(of: ".", with: "_")
        let msg = message.toAnyObject()
        reference.child(fixedSeller).child("chats").child("\(itemID)").child(fixedBuyer).child(message.messageId).setValue(msg)
    }
    
    // load chat before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getChat()
    }
    
    // load current chat
    func getChat() {
        guard !isPushedByChats else { return }
        
        let fixedSeller = seller.replacingOccurrences(of: ".", with: "_")
        let fixedBuyer = buyer.replacingOccurrences(of: ".", with: "_")
        
        DispatchQueue.global().async { [weak self] in
            guard let itemID = self?.itemID else { return }
            
            self?.reference.child(fixedSeller).child("chats").child("\(itemID)").child(fixedBuyer).observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String] {
                    print(value)
                }
            }
        }
    }
    
}
