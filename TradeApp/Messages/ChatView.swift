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
import FirebaseAuth

class ChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var chatTitle: String!
    var itemId: String!
    
    static var buyer: String!
    static var seller: String!
    
//    var isPushedByChats: Bool!
    
    var reference: DatabaseReference!
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = chatTitle
        navigationItem.largeTitleDisplayMode = .never

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(insertMessage), name: NSNotification.Name("newMessage"), object: nil)
        
        setLayout()
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        DispatchQueue.global().async { [weak self] in
            self?.getChat() { chat in
                self?.messages = chat
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }
    }
    
    // return current sender
    func currentSender() -> SenderType {
        let user = Auth.auth().currentUser?.uid ?? "nil"
        return Sender(senderId: user, displayName: "")
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
        guard !text.isEmpty else { return }
        
        sendMessage(seller: ChatView.seller, buyer: ChatView.buyer, itemId: itemId, text: text) { [weak self] in
            guard let messagesCount = self?.messages.count else { return }
            
            var indexPath = IndexPath()
            
            if messagesCount > 0 {
                indexPath = IndexPath(index: messagesCount - 1)
            } else {
                indexPath = IndexPath(index: 0)
            }
            
            self?.messagesCollectionView.insertItems(at: [indexPath])
            inputBar.inputTextView.text = nil
            self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
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
    
    // send message function
    @objc func sendMessage(seller: String, buyer: String, itemId: String, text: String, completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                
                var ownerMessageId = 0
                
                if snapshot.hasChildren() {
                    if let lastMessage = snapshot.value as? [String: [String: String]] {
                        ownerMessageId = Int((lastMessage.values.first?["messageId"])!)! + 1
                    }
                }
                
                self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                    
                    var buyerMessageId = 0
                    
                    if snapshot.hasChildren() {
                        if let lastMessage = snapshot.value as? [String: [String: String]] {
                            buyerMessageId = Int((lastMessage.values.first?["messageId"])!)! + 1
                        }
                    }
                    
                    let sender = Sender(senderId: user, displayName: "")
                    
                    let ownerMessage = Message(sender: sender, messageId: "\(ownerMessageId)", sentDate: Date(), kind: .text(text))
                    let buyerMessage = Message(sender: sender, messageId: "\(buyerMessageId)", sentDate: Date(), kind: .text(text))
                    
                    self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("messages").child("m\(ownerMessageId)").setValue(ownerMessage.toAnyObject())
                    
                    self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("messages").child("m\(buyerMessageId)").setValue(buyerMessage.toAnyObject())
                    
                    if user == seller {
                        self?.messages.append(ownerMessage)
                    } else {
                        self?.messages.append(buyerMessage)
                    }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    // do not hide input bar when scroll view is on top
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isFirstResponder {
            self.becomeFirstResponder()
        }
    }
    
    // add observer if not moving from parent
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !isMovingFromParent {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        } else {
            messages.removeAll()
        }
    }
    
    // load current chat
    func getChat(completion: @escaping ([Message]) -> Void) {
//        guard !isPushedByChats else { return }
        
        var currentChat = [Message]()
        
        guard let itemId = itemId else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(ChatView.buyer).child("chats").child("\(itemId)").child(ChatView.seller).child("messages").observeSingleEvent(of: .value) { snapshot in
                if let chat = snapshot.value as? [String: [String: String]] {
                    
                    let sortedChat = chat.sorted {$0.key < $1.key}
                    let arrayChat = sortedChat.map {$0.value}
                    
                    for message in arrayChat {
                        let sender = Sender(senderId: message["sender"]!, displayName: "")
                        let message = Message(sender: sender, messageId: message["messageId"]!, sentDate: message["sentDate"]!.toDate(), kind: .text(message["kind"]!))
                        currentChat.append(message)
                    }
                    
                    guard currentChat.count == chat.count else { return }
                    
                    DispatchQueue.main.async {
                        completion(currentChat)
                    }
                }
            }
        }
    }
    
    // get new message and add it to messages array
//    @objc func insertMessage(_ notification: NSNotification) {
//        guard let message = notification.userInfo!["message"] as? [String: String] else { return }
//        let sender = Sender(senderId: message["sender"]!, displayName: "")
//        let msg = Message(sender: sender, messageId: message["messageId"]!, sentDate: (message["sentDate"]?.toDate())!, kind: .text(message["kind"]!))
//
//        let indexPath = IndexPath(index: messages.count)
//        messages.append(msg)
//        messagesCollectionView.insertItems(at: [indexPath])
//    }
    
}
