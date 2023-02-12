//
//  LoginView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit

class LoginView: UITableViewController {
    
    var sections = ["Segment", "Email", "Password", "Button"]
    
    var segment: SegmentedControllCell!
    var email: TextFieldCell!
    var password: TextFieldCell!
    var repeatPassword: TextFieldCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set header title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section] == "Segment" || sections[section] == "Button" {
            return " "
        } else {
            return sections[section]
        }
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell", for: indexPath) as? SegmentedControllCell {
            if sections[indexPath.section] == "Segment" {
                cell.segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
                cell.segment.addTarget(self, action: #selector(handleSegmentChange), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                segment = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell", for: indexPath) as? TextFieldCell {
            switch sections[indexPath.section] {
            case "Email":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "none"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                email = cell
                return cell
            case "Password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "none"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                password = cell
                return cell
            case "Repeat password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "none"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                repeatPassword = cell
                return cell
                
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sections[indexPath.section] == "Button" {
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // set action for segment change
    @objc func handleSegmentChange(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        
        if sender.selectedSegmentIndex == 0 {
            sections = ["Segment", "Email", "Password", "Button"]
        } else {
            sections = ["Segment", "Email", "Password", "Repeat password", "Button"]
        }
        
        tableView.reloadData()
    }
    
    

}
