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
    
    var chats = [String: [String: [Chat]]]()
//    var chats = [String: [String: [Message]]]()
    var chatsData = [String: [String: Any]]()
    
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
        return chats.values.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell {
            let chatID = Array(chats.keys)[indexPath.row]
            let chatsValues = chats.values
            
            let image = chatsData[chatID]?["thumbnail"] as! UIImage
            cell.thumbnail.image = image
            cell.title.text = chatsData[chatID]?["title"] as? String
            cell.title.font = UIFont.systemFont(ofSize: 18)
//            cell.subtitle.text = "\(getMessageText((chats[chatKey]?.last?.kind)!)) •  \(MessageKitDateFormatter.shared.string(from: (chats[chatKey]?.last?.sentDate)!))"
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
            
            let chatsTemp = chats.values
            let chatID = Array(chats.keys)[indexPath.row]
            let traderID = Array(chatsTemp)[indexPath.row]
//            let chatUser = Array(chats[chatId]?.values)[indexPath.row]
            vc.chatTitle = chatsData["\(chatID)"]?["title"] as? String
            ChatView.buyer = ""
            ChatView.seller = ""
            vc.isPushedByChats = true
            vc.itemID = Int(chatID)
//            vc.messages = chats[chatID]?[traderID] ?? [Message]()
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
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                let chatKey = Array(self.chats.keys)[indexPath.row]
                self.chats.removeValue(forKey: chatKey)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.isArrayEmpty()
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
                print(self?.chats.values)
                
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
    func loadChats(completion: @escaping ([String: [String: [Message]]]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
//        var result = [String: [Message]]()
        
        var result = [String: [String: [Message]]]()
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").observeSingleEvent(of: .value) { snapshot in
                if let chats = snapshot.value as? [String: [String: [[String: String]]]] {
                    
                    for (id, traders) in chats {
                        for trader in traders {
                            self?.getChatData(trader: trader.key, id: id) { data in
                                self?.chatsData[id] = data
                                
                                self?.toMessageModel(chat: trader.value) { messages in
                                    let dict = [trader.key: messages]
                                    result[id] = dict
                                    
                                    guard result.values.count == chats.values.count else { return }
                                    completion(result)
                                }
                            }
                        }
                    }
                    
                    
                    
//                    for (id, buyer) in chats {
//                        print("first loop")
//                        let children = buyer.keys
//                        
//                        for child in children {
//                            print(child)
//                            self?.getChatData(trader: child, id: id) { data in
//                                self?.chatsData = data
//                                
//                                for chat in buyer {
//                                    print("third loop")
//                                    for message in chat.value {
//                                        print("fourth loop")
//                                        let sender = Sender(senderId: message["sender"]!, displayName: "")
//                                        let messageId = message["messageId"]!
//                                        let sentDate = message["sentDate"]!.toDate()
//                                        let kind = message["kind"]!
//                                        
//                                        let msg = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(kind))
//                                        
//                                        if result[id] == nil {
//                                            result[id] = [msg]
//                                        } else {
//                                            result[id]?.append(msg)
//                                        }
//                                        
//                                        print(result)
//                                        guard result.keys.count == 2 else { return }
//                                        
//                                        completion(result)
//                                        
//                                    }
//                                }
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    // get chat title and thumbnail
    func getChatData(trader: String, id: String, completion: @escaping ([String: [String: Any]]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        var result = [String: [String: Any]]()
        
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
                                result[id] = ["title": title!, "thumbnail": thumbnail]
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

}
