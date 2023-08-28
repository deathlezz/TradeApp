//
//  MessagesView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import MessageKit
import Firebase

class MessagesView: UITableViewController {
    
    var emptyArrayView: UIView!
    
    var loggedUser: String!
    
    var chats = [String: [Message]]()
    var chatsData = [String: [String: String]]()
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: NSNotification.Name("signOut"), object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
                
        addEmptyArrayView()
    }
    
    // set number of items in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "messageCell")
        let conf = UIImage.SymbolConfiguration(scale: .large)
        let chatKey = Array(chats.keys)[indexPath.row]
        cell.textLabel?.text = chatsData["\(chatKey)"]?["title"]
        cell.detailTextLabel?.text = "\(getMessageText((chats[chatKey]?.last?.kind)!)) • \(chats[chatKey]?.last?.sentDate.toString(shortened: true) ?? "") • \(MessageKitDateFormatter.shared.string(from: (chats[chatKey]?.last?.sentDate)!))"
        cell.detailTextLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(systemName: "photo", withConfiguration: conf)
        return cell
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
            let chatTitle = Array(chats.keys)[indexPath.row]
            vc.chatTitle = chatTitle
            ChatView.shared.buyer = ""
            ChatView.shared.seller = ""
            vc.isPushedByChats = true
            vc.loggedUser = loggedUser
            vc.messages = chats[chatTitle] ?? [Message]()
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
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
        
        loadChats() { conv in
            self.chats = conv
            self.isArrayEmpty()
            self.tableView.reloadData()
        }

    }
    
    // set up empty array view
    func addEmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - 175, width: 200, height: 50))
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
    
    // sign out current user
    @objc func signOut() {
        navigationController?.popViewController(animated: true)
    }
    
    // convert message kind text into string
    func getMessageText(_ messageKind: MessageKind) -> String {
        if case .text(let value) = messageKind {
            if value.count > 32 {
                return value.prefix(32) + "..."
            } else {
                return value
            }
        }
        return ""
    }
    
    // load user chats
    func loadChats(completion: @escaping ([String: [Message]]) -> Void) {
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        var result = [String: [Message]]()
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(mail).child("chats").observeSingleEvent(of: .value) { snapshot in
                if let conversations = snapshot.value as? [String: [String: [[String: String]]]] {
                    for (id, buyer) in conversations {
                        
                        let children = buyer.keys
                        
                        for child in children {
                            
                            self?.getChatData(child: child, id: id) { data in
                                self?.chatsData = data
                                
                                for chat in buyer {
                                    for message in chat.value {
                                        let sender = Sender(senderId: message["sender"]!, displayName: "")
                                        let messageId = message["messageId"]!
                                        let sentDate = message["sentDate"]!.toDate()
                                        let kind = message["kind"]!
                                        
                                        let msg = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(kind))
                                        
                                        if result.isEmpty {
                                            result[id] = [msg]
                                        } else {
                                            result[id]?.append(msg)
                                        }
                                    }
                                    
                                    guard result.count == conversations.count else { return }
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
    func getChatData(child: String, id: String, completion: @escaping ([String: [String: String]]) -> Void) {
        var result = [String: [String: String]]()
        
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        let userCases = [child, mail]
        let itemsCases = ["activeItems", "endedItems"]
        
        DispatchQueue.global().async { [weak self] in
            for userCase in userCases {
                for itemsCase in itemsCases {
                    self?.reference.child(userCase).child(itemsCase).child(id).observeSingleEvent(of: .value) { snapshot in
                        
                        if let value = snapshot.value as? [String: Any] {
                            let photos = value["photos"] as? [String: String]
                            let title = value["title"] as? String
                            let thumbnail = photos?["image0"]
                            
                            print(id)
                            
                            if result.isEmpty {
                                result[id] = ["title": title!, "thumbnail": thumbnail!]
                            } else {
                                result[id]?["title"] = title
                                result[id]?["thumbnail"] = thumbnail
                            }
                            
//                            result[id]?["title"] = title
//                            result[id]?["thumbnail"] = thumbnail
                            completion(result)
                            
                        }
                    }
                }
            }
        }
    }

}
