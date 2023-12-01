//
//  MessagesView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import MessageKit
import Firebase
import FirebaseAuth

class MessagesView: UITableViewController {
    
    var emptyArrayView: UIView!
    
    var chats = [Chat]()
//    var chats = [String: [String: [Message]]]()
//    var chatsData = [String: [String: Any]]()
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
                
        addEmptyArrayView()
    }
    
    // set number of items in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell {
            cell.thumbnail.image = chats[indexPath.row].thumbnail
            cell.title.text = chats[indexPath.row].title
            cell.title.font = UIFont.systemFont(ofSize: 18)
            cell.subtitle.text = "\(getMessageText((chats[indexPath.row].messages.last?.kind)!)) •  \(MessageKitDateFormatter.shared.string(from: (chats[indexPath.row].messages.last?.sentDate)!))"
            cell.subtitle.textColor = .darkGray
            cell.subtitle.font = UIFont.systemFont(ofSize: 12)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
            ChatView.buyer = chats[indexPath.row].buyer
            ChatView.seller = chats[indexPath.row].itemOwner
            vc.chatTitle = chats[indexPath.row].title
            vc.isPushedByChats = true
            vc.itemId = chats[indexPath.row].itemId
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set table view cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / 6
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Delete chat", message: "Are you sure, you want to delete this chat?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let chat = self?.chats[indexPath.row] else { return }
                
                self?.deleteChat(itemId: chat.itemId, buyer: chat.buyer, seller: chat.itemOwner) {
                    self?.chats.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.isArrayEmpty()
                }
            })
            present(ac, animated: true)
        }
    }
    
    // set empty array view before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async { [weak self] in
            self?.loadChats() { conv in
                self?.chats = conv
                
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let safeArea = (navigationController?.navigationBar.frame.maxY)!
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - safeArea - 25, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .white
        myView.addSubview(label)
        view.addSubview(myView)
        emptyArrayView = myView
    }
    
    // check if array is empty or not
    func isArrayEmpty() {
        if chats.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // convert message kind text into string
    func getMessageText(_ messageKind: MessageKind) -> String {
        if case .text(let value) = messageKind {
            
            let width = UIScreen.main.bounds.width
            let maxLetters = Int(width / 14)
            
            if value.count > maxLetters {
                return value.prefix(maxLetters) + "..."
            } else {
                return value
            }
        }
        return ""
    }
    
    // load user chats
    func loadChats(completion: @escaping ([Chat]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
            
        var result = [Chat]()
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").observeSingleEvent(of: .value) { snapshot in
                if let chats = snapshot.value as? [String: [String: [String: Any]]] {
                    
                    for (id, traders) in chats {
                        for trader in traders {
                            self?.getChatData(trader: trader.key, id: id) { data in
                                let chatTitle = data["title"] as? String
                                let chatThumbnail = data["thumbnail"] as? UIImage
                                
                                let chatData = trader.value["messages"] as! [[String: String]]
                                let itemOwner = trader.value["itemOwner"] as! String
                                let buyer = trader.value["buyer"] as! String
                                
                                self?.toMessageModel(chat: chatData) { messages in
                                    
                                    let chat = Chat(messages: messages, itemId: id, itemOwner: itemOwner, buyer: buyer, title: chatTitle, thumbnail: chatThumbnail)
                                    result.append(chat)
                                    
                                    guard result.count == chats.values.count else { return }
                                    completion(result)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // get chat title and thumbnail
    func getChatData(trader: String, id: String, completion: @escaping ([String: Any]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        var result = [String: Any]()
        
        let userCases = [trader, user]
        let itemsCases = ["activeItems", "endedItems"]
        
        DispatchQueue.global().async { [weak self] in
            for userCase in userCases {
                for itemsCase in itemsCases {
                    self?.reference.child(userCase).child(itemsCase).child(id).observeSingleEvent(of: .value) { snapshot in
                        
                        if let value = snapshot.value as? [String: Any] {
                            let photos = value["photosURL"] as? [String]
                            let title = value["title"] as? String
                            let url = photos?[0]

                            // convert URL to UIImage here
                            self?.getThumbnail(url: url!) { thumbnail in
                                result = ["title": title!, "thumbnail": thumbnail]
                                completion(result)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // convert image URL to UIImage
    func getThumbnail(url: String, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let url = URL(string: url) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                
                if let data = data {
                    DispatchQueue.main.async {
                        guard let thumbnail = UIImage(data: data) else { return }
                        completion(thumbnail)
                    }
                }
            }

            task.resume()
        }
    }
    
    // convert array of dictionaries chat to array of messages
    func toMessageModel(chat: [[String: String]], completion: @escaping ([Message]) -> Void) {
        var result = [Message]()
        
        for message in chat {
            let sender = Sender(senderId: message["sender"]!, displayName: "")
            let messageId = message["messageId"]!
            let sentDate = message["sentDate"]!.toDate()
            let kind = message["kind"]!
            
            let msg = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(kind))
            result.append(msg)
        }
        
        guard result.count == chat.count else { return }
        completion(result)
    }
    
    // delete chat from Firebase
    func deleteChat(itemId: String, buyer: String, seller: String, completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        var child: String
        
        if user == buyer {
            child = seller
        } else {
            child = buyer
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").child(itemId).child(child).removeValue() {error, _ in
                guard error == nil else { return }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    

}
