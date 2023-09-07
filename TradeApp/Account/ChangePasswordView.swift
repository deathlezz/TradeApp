//
//  ChangePasswordView.swift
//  TradeApp
//
//  Created by deathlezz on 02/03/2023.
//

import UIKit
import Firebase

class ChangePasswordView: UITableViewController {
    
    let sections = ["Current password", "New password", "Repeat password", "Button"]
    
    var cells = [TextFieldCell]()    
    var mail: String!
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change password"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
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
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let headerX = view.readableContentGuide.layoutFrame.minX
            
        let label = UILabel()
        
        if section == 0 {
            label.frame = CGRect.init(x: headerX, y: 11, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else {
            label.frame = CGRect.init(x: headerX, y: -20, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        }
        
        label.text = section == 3 ? " " : sections[section]
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 45 : 15
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as? TextFieldCell {
            switch sections[indexPath.section] {
            case "Current password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.isSecureTextEntry = true
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            case "New password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourNewPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.isSecureTextEntry = true
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            case "Repeat password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourNewPassword123"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.isSecureTextEntry = true
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
        guard let currentPassword = cells[0].textField.text else { return }
        guard let newPassword = cells[1].textField.text else { return }
        guard let repeatPassword = cells[2].textField.text else { return }
        
        guard !currentPassword.isEmpty && !newPassword.isEmpty && !repeatPassword.isEmpty else {
            return showAlert(title: "Empty field", message: "All text fields have to be filled")
        }
        
        guard isPasswordValid() else {
            return showAlert(title: "Error", message: "Incorrect password format")
        }
        
        guard newPassword != currentPassword else {
            cells[1].textField.text = nil
            cells[2].textField.text = nil
            return showAlert(title: "Error", message: "New password can't be the same as the old one")
        }
        
        guard repeatPassword == newPassword else {
            cells[2].textField.text = nil
            return showAlert(title: "Error", message: "Password repeated incorrectly")
        }
        
        let fixedMail = mail.replacingOccurrences(of: ".", with: "_")
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(fixedMail).child("password").observeSingleEvent(of: .value) { snapshot in
                if let pass = snapshot.value as? String {
                    
                    DispatchQueue.main.async {
                        guard currentPassword == pass else {
                            for cell in (self?.cells)! {
                                cell.textField.text = nil
                            }
                            return self?.showAlert(title: "Error", message: "Wrong current password") ?? ()
                        }
                        
                        DispatchQueue.global().async {
                            self?.changePassword(to: newPassword)
                        }
                    }
                }
            }
        }
    }
    
    // set password change function
    func changePassword(to: String) {
        let fixedMail = mail.replacingOccurrences(of: ".", with: "_")
        reference.child(fixedMail).child("password").setValue(to)
        Utilities.setUser(nil)
        
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Password has been changed", message: "You can sign in now", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            self?.present(ac, animated: true)
        }
        
    }
    
    // check password format
    // check if password has minimum 8 characters at least 1 uppercase alphabet, 1 lowercase alphabet and 1 number
    func isPasswordValid() -> Bool {
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,16}$"
        let passPred = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passPred.evaluate(with: cells[1].textField.text)
    }

}
