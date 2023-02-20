//
//  AccountView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit

class AccountView: UITableViewController {
    
    let sections = ["User", "Your ads", "Settings", "Log out"]
    let settingsSection = ["Edit profile", "Change email", "Change password", "Delete account"]
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountCell")
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 3:
            return 1
        case 1:
            return 2
        default:
            return 4
        }
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.01
        }
        
        return CGFloat()
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)

        switch sections[indexPath.section] {
        case "User":
            cell.textLabel?.text = mail
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.backgroundColor = .systemGray6
            cell.textLabel?.textColor = .darkGray
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        case "Your ads":
            if indexPath.row == 0 {
                cell.textLabel?.text = "Active: 0"
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(systemName: "checkmark")
            } else {
                cell.textLabel?.text = "Ended: 0"
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(systemName: "xmark")
            }
            return cell
        case "Settings":
            switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(systemName: "person")
            case 1:
                cell.imageView?.image = UIImage(systemName: "at")
            case 2:
                cell.imageView?.image = UIImage(systemName: "lock")
            default:
                cell.imageView?.image = UIImage(systemName: "trash")
            }
            
            cell.textLabel?.text = settingsSection[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            cell.textLabel?.text = "Sign out"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            cell.accessoryType = .none
            return cell
        }
    }
    
}
