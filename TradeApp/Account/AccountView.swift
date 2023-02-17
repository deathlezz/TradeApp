//
//  AccountView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit

class AccountView: UITableViewController {
    
    let sections = ["Your ads", "Settings", "Log out"]
    let settingsSection = ["Edit profile", "Change email", "Change password", "Delete account"]
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.isScrollEnabled = false
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    // set header title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 2 ? " " : sections[section]
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2:
            return 2
        default:
            return 4
        }
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)

        switch sections[indexPath.section] {
        case "Your ads":
            if indexPath.row == 0 {
                cell.textLabel?.text = "Active: 0"
            } else {
                cell.textLabel?.text = "Ended: 0"
            }
            return cell
        case "Settings":
            cell.textLabel?.text = settingsSection[indexPath.row]
            return cell
        default:
            if indexPath.row == 0 {
                cell.textLabel?.text = mail
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.textLabel?.text = "Log out"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .systemRed
                cell.accessoryType = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            }
            return cell
        }
    }
    
}
