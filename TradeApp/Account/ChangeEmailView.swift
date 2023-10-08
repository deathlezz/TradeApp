//
//  ChangeEmailView.swift
//  TradeApp
//
//  Created by deathlezz on 01/03/2023.
//

import UIKit
//import Firebase
import FirebaseAuth

class ChangeEmailView: UITableViewController {
    
    let sections = ["Current email", "New email", "Button"]
    
    var currentEmail: TextFieldCell!
    var newEmail: TextFieldCell!
    
//    var loggedUser: String!
    
//    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change email"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
        
//        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
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
        
        label.text = section == 2 ? " " : sections[section]
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
                cell.submitButton.setTitle("Verify", for: .normal)
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
                
        guard currentMailText == Auth.auth().currentUser?.email else {
            return showAlert(title: "Error", message: "Incorrect current address")
        }
        
        guard currentMailText != newMailText else {
            return showAlert(title: "Error", message: "New email can't be the same as the old one")
        }
        
        guard isEmailValid() else {
            return showAlert(title: "Error", message: "Incorrect new email format")
        }
        
        saveEmail(email: newMailText)
    }
    
    // show alert function
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // save email to Firebase Auth
    func saveEmail(email: String) {
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { [weak self] error in

            guard error == nil else {
                self?.showAlert(title: "Sent email failed", message: error!.localizedDescription)
                return
            }
            
//            self?.showAlert(title: "Email sent to \(email)", message: "Verify email and tap Continue to proceed")
            
            let ac = UIAlertController(title: "Email sent to \(email)", message: "Verify email and tap Continue to proceed", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true)
        }
        
        
        
        Auth.auth().currentUser?.updateEmail(to: email) { [weak self] error in
            guard error == nil else {
                self?.showAlert(title: "Change email failed", message: error!.localizedDescription)
                return
            }
            
            let ac = UIAlertController(title: "Email has been changed", message: "You can sign in now", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                do {
                    try Auth.auth().signOut()
                    self?.navigationController?.popToRootViewController(animated: true)
                } catch {
                    self?.showAlert(title: "Sign out failed", message: "An internal error occurred")
                }
            })
            self?.present(ac, animated: true)
        }
    }
    
    // send verification email into new inbox
    func sendEmail(email: String) {
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { [weak self] error in

            guard error == nil else {
                self?.showAlert(title: "Sent email failed", message: error!.localizedDescription)
                return
            }
            
            self?.showAlert(title: "Email sent", message: "Check your inbox to verify your new email")
        }
    }
    
}
