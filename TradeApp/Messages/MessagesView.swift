//
//  MessagesView.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import UIKit
import Network

class MessagesView: UITableViewController {
    
    let monitor = NWPathMonitor()
    var connectedOnLoad: Bool!
    var connected: Bool!
    
    var messages = ["message"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        checkConnection()
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
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // check for internet connection
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            
            if self.connectedOnLoad != nil {
                self.connected = !self.connected
                self.pushToNoConnectionView()
                print("Connected: \(self.connected!)")
            }
            
            guard self.connectedOnLoad == nil else { return }
            
            if path.status == .satisfied {
                self.connectedOnLoad = true
                self.connected = true
            } else {
                self.connectedOnLoad = false
                self.connected = false
            }
            
            self.pushToNoConnectionView()
            print("Connected: \(self.connected!)")
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // show no connection view
    func pushToNoConnectionView() {
        DispatchQueue.main.async {
            if self.connected == false {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                    vc.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }

}
