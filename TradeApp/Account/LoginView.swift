//
//  LoginView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit

enum AccountAction {
    case login
    case register
}

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
                cell.textField.placeholder = "youremail@domain.com"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                email = cell
                return cell
            case "Password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.isSecureTextEntry = true
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                password = cell
                return cell
            case "Repeat password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.isSecureTextEntry = true
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
                cell.selectionStyle = .none
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
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
        if sender.selectedSegmentIndex == 0 {
            sections = ["Segment", "Email", "Password", "Button"]
            let indexSet = IndexSet(integer: sections.count - 1)
            tableView.deleteSections(indexSet, with: .automatic)
        } else {
            sections = ["Segment", "Email", "Password", "Repeat password", "Button"]
            let indexSet = IndexSet(integer: sections.count - 2)
            tableView.insertSections(indexSet, with: .automatic)
        }
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        let mail = email.textField.text!
        let passText = password.textField.text
        let rePassText = repeatPassword.textField.text
        
        if segment.segment.selectedSegmentIndex == 0 {
            
            if users.contains(where: {$0.key == mail}) {
                guard users[mail] == passText else {
                    password.textField.text = nil
                    return showAlert(title: "Error", message: "Wrong password")
                }
                
                resetView(.login)
                
                if let vc = storyboard?.instantiateViewController(withIdentifier: "AccountView") as? AccountView {
                    vc.mail = mail
//                    let mySceneDelegate = view.window?.windowScene?.keyWindow
//                    mySceneDelegate?.rootViewController = vc
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                showAlert(title: "Error", message: "Wrong email address")
            }
            
        } else {
            guard isEmailValid() else {
                return showAlert(title: "Invalid email format", message: "Use this format instead \n*mail@domain.com*")
            }
            
            guard isPasswordValid() else {
                return showAlert(title: "Invalid password format", message: "Use this format instead \n*yourPassword123*")
            }
            
            guard passText == rePassText else {
                repeatPassword.textField.text = nil
                return showAlert(title: "Password repeated incorrectly", message: "Re-enter password again")
            }
            
            // new user account created
            if !users.contains(where: {$0.key == mail}) {
                users[mail] = passText
                resetView(.register)
                showAlert(title: "Success", message: "You can sign in now")
                
            } else {
                showAlert(title: "Error", message: "This email is already used")
            }
        }
    }
    
    // check email address format "mail@domain.com"
    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if emailPred.evaluate(with: email.textField.text) {
            return true
        } else {
            return false
        }
    }
    
    // check password format
    // check if password has minimum 8 characters at least 1 uppercase alphabet, 1 lowercase alphabet and 1 number
    func isPasswordValid() -> Bool {
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,16}$"
        let passPred = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        
        if passPred.evaluate(with: password.textField.text) {
            return true
        } else {
            return false
        }
    }
    
    // set alert for incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // reset view after user account creation
    func resetView(_ after: AccountAction) {
        email.textField.text = nil
        password.textField.text = nil
        repeatPassword.textField.text = nil
        
        guard after == .register else { return }
        segment.segment.selectedSegmentIndex = 0
        handleSegmentChange(segment.segment)
    }

}
