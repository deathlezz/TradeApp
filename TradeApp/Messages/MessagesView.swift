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
        cell.textLabel?.text = chatKey
        cell.detailTextLabel?.text = "\(getMessageText((chats[chatKey]?.last?.kind)!)) • \(MessageKitDateFormatter.shared.string(from: (chats[chatKey]?.last?.sentDate)!))"
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
            vc.buyer = ""
            vc.seller = ""
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
        loadChats()
        isArrayEmpty()
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
    func loadChats() {
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(mail).child("chats").observeSingleEvent(of: .value) { snapshot in
                if let conversations = snapshot.value as? [String: [String: Any]] {
                    for (id, buyer) in conversations {
                        
                        guard let buyer = buyer as? [String: [String: String]] else { return }
                        
                        for chat in buyer {
                            guard let messages = chat as? [String: [String: String]] else { return }
                            
                            for message in messages {
                                let sender = Sender(senderId: message.value["sender"]!, displayName: "")
                                let messageId = message.value["messageId"]!
                                let sentDate = message.value["sentDate"]!.toDate()
                                let kind = message.value["kind"]!
                                
                                let msg = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(kind))
                                
                                self?.chats[id]?.append(msg)
                            }
                        }
                        
                    }
                }
            }
        }
        
        
//        guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == loggedUser}) else { return }
//        chats = AppStorage.shared.users[index].chats
    }

}
