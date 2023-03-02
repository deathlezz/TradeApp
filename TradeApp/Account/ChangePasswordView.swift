//
//  ChangePasswordView.swift
//  TradeApp
//
//  Created by deathlezz on 02/03/2023.
//

import UIKit

class ChangePasswordView: UITableViewController {
    
    let sections = ["Current password", "New password", "Repeat password", "Button"]
    
//    var currentPassword: TextFieldCell!
//    var newPassword: TextFieldCell!
//    var repeatPassword: TextFieldCell!
    
    var cells = [TextFieldCell]()
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change password"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set header title fo each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 3 ? " " : sections[section]
    }
    
    // set number of items in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as? TextFieldCell {
            switch sections[indexPath.section] {
            case "Current password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            case "New password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourNewPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            case "Repeat password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourNewPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sections[indexPath.section] == "Button" {
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // set alert for incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        
        
    }
    
    // set password change function
    func changePassword(to: String) {
        
    }
    
    
    
    

}
