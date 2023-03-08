//
//  ChangeEmailView.swift
//  TradeApp
//
//  Created by deathlezz on 01/03/2023.
//

import UIKit

class ChangeEmailView: UITableViewController {
    
    let sections = ["Current email", "New email", "Button"]
    
    var currentEmail: TextFieldCell!
    var newEmail: TextFieldCell!
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change email"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set header title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 2 ? " " : sections[section]
    }
    
    // set number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath) as? TextFieldCell {
            switch sections[indexPath.section] {
            case "Current email":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "email@domain.com"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                currentEmail = cell
                return cell
            case "New email":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "email@domain.com"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                newEmail = cell
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
    
    // check email address format
    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: newEmail.textField.text)
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        guard let currentMailText = currentEmail.textField.text else { return }
        guard let newMailText = newEmail.textField.text else { return }
                
        guard currentMailText == mail else {
            return showAlert(title: "Error", message: "Incorrect current address")
        }
        
        guard currentMailText != newMailText else {
            return showAlert(title: "Error", message: "New email can't be the same as the old one")
        }
        
        guard isEmailValid() else {
            return showAlert(title: "Error", message: "Incorrect new email format")
        }
        
        changeEmail(to: newMailText)
    }
    
    // set alert for incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // set email change function
    func changeEmail(to: String) {
        guard let mail = mail else { return }
        
        let password = users[mail]
        users[mail] = nil
        users[to] = password
        Utilities.setUser(nil)
        
        let ac = UIAlertController(title: "Email has been changed", message: "You can sign in now", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
}
