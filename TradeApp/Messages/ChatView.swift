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
        
        setLayout()
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        DispatchQueue.global().async { [weak self] in
            self?.getChat() { chat in
                guard let chat = chat else {
                    self?.showAlert()
                    return
                }
                
                self?.messages = chat
                self?.chatRead()
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
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
        DispatchQueue.global().async { [weak self] in
            self?.checkIfItemExists(id: itemId, owner: seller) { exists in
                if exists {
                    guard let user = Auth.auth().currentUser?.uid else { return }
                    let sender = Sender(senderId: user, displayName: "")
                    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                    
                    self?.sendMessageToSeller(sender: sender, user: user, seller: seller, buyer: buyer, itemId: itemId, text: text, timestamp: timestamp) {
                        self?.sendMessageToBuyer(sender: sender, user: user, seller: seller, buyer: buyer, itemId: itemId, text: text, timestamp: timestamp, completion: completion)
                    }
                    
                } else {
                    // show alert and pop view back
                    self?.showAlert()
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
    func getChat(completion: @escaping ([Message]?) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        guard let itemId = itemId else { return }
        
        var currentChat = [Message]()
        
        var child: String
        
        if user == ChatView.seller {
            child = ChatView.buyer
        } else {
            child = ChatView.seller
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").child("\(itemId)").child(child).child("messages").observeSingleEvent(of: .value) { snapshot in
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
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // update chat "read" value on Firebase
    func chatRead() {
        guard let user = Auth.auth().currentUser?.uid else { return }
        guard let itemId = itemId else { return }
        
        var child: String
        
        if user == ChatView.seller {
            child = ChatView.buyer
        } else {
            child = ChatView.seller
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").child("\(itemId)").child(child).child("read").setValue(true)
        }
    }
    
    // show "chat not found" alert
    func showAlert() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Chat not found", message: "Item has been deleted", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                self?.navigationController?.popViewController(animated: true)
            })
            self?.present(ac, animated: true)
        }
    }
    
    // check if item exists
    func checkIfItemExists(id: String, owner: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("activeItems").child(id).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    completion(true)
                    return
                }

                self?.reference.child(owner).child("endedItems").child(id).observeSingleEvent(of: .value) { snapshot in
                    completion(snapshot.exists())
                }
            }
        }
    }
    
    // send message to seller
    func sendMessageToSeller(sender: Sender, user: String, seller: String, buyer: String, itemId: String, text: String, timestamp: Int, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.hasChildren() {
                    if let lastMessage = snapshot.value as? [String: [String: String]] {
                        let ownerMessageId = Int((lastMessage.values.first?["messageId"])!)! + 1
                        
                        let ownerMessage = Message(sender: sender, messageId: "\(ownerMessageId)", sentDate: Date(), kind: .text(text))
                        self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("messages").child("\(timestamp)").setValue(ownerMessage.toAnyObject())
                        
                        if user == seller {
                            self?.messages.append(ownerMessage)
                            self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("read").setValue(true)
                            self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("read").setValue(false)
                        }
                    }
                } else {
                    let ownerMessage = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text(text))
                    let ownerChat = Chat(messages: [ownerMessage], itemId: String(itemId), itemOwner: seller, buyer: user)
                    self?.reference.child(seller).child("chats").child("\(itemId)").child(user).setValue(ownerChat.toAnyObject())
                    
                    if user == seller {
                        self?.messages.append(ownerMessage)
                        self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("read").setValue(true)
                        self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("read").setValue(false)
                    }
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // send message to buyer
    func sendMessageToBuyer(sender: Sender, user: String, seller: String, buyer: String, itemId: String, text: String, timestamp: Int, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.hasChildren() {
                    if let lastMessage = snapshot.value as? [String: [String: String]] {
                        let buyerMessageId = Int((lastMessage.values.first?["messageId"])!)! + 1
                        
                        let buyerMessage = Message(sender: sender, messageId: "\(buyerMessageId)", sentDate: Date(), kind: .text(text))
                        self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("messages").child("\(timestamp)").setValue(buyerMessage.toAnyObject())
                        
                        if user == buyer {
                            self?.messages.append(buyerMessage)
                            self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("read").setValue(true)
                            self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("read").setValue(false)
                        }
                    }
                } else {
                    let buyerMessage = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text(text))
                    let buyerChat = Chat(messages: [buyerMessage], itemId: String(itemId), itemOwner: seller, buyer: user)
                    self?.reference.child(seller).child("chats").child("\(itemId)").child(user).setValue(buyerChat.toAnyObject())
                    
                    if user == buyer {
                        self?.messages.append(buyerMessage)
                        self?.reference.child(buyer).child("chats").child("\(itemId)").child(seller).child("read").setValue(true)
                        self?.reference.child(seller).child("chats").child("\(itemId)").child(buyer).child("read").setValue(false)
                    }
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}
