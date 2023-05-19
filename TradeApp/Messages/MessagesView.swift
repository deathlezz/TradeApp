//
//  MessagesView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit

class MessagesView: UITableViewController {
    
    var emptyArrayView: UIView!
    
    var loggedUser: String!
    
    var messages = ["BMW E36 2.0 LPG"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: NSNotification.Name("signOut"), object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        addEmptyArrayView()
    }
    
    // set number of items in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "messageCell")
        let conf = UIImage.SymbolConfiguration(scale: .large)
        cell.textLabel?.text = messages[indexPath.row]
        cell.detailTextLabel?.text = "latest sent message"
        cell.detailTextLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(systemName: "photo", withConfiguration: conf)
        return cell
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
            vc.chatTitle = messages[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            isArrayEmpty()
        }
    }
    
    // set empty array view before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        if messages.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // sign out current user
    @objc func signOut() {
        navigationController?.popViewController(animated: true)
    }

}
