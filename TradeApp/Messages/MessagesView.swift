//
//  MessagesView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit

class MessagesView: UITableViewController {
    
    var messages = ["message"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    // set number of items in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        cell.textLabel?.text = "John Smith"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // set action or tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
