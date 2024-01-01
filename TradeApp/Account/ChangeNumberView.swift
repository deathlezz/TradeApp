//
//  ChangeNumberView.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import UIKit
import Firebase
import FirebaseAuth

enum NumberAction {
    case add
    case delete
}

class ChangeNumberView: UITableViewController {
    
    var sections = ["New number", "Button"]
    
    var firstHeader: UILabel!
    var secondHeader: UILabel!
    
    var currentNumber: UITableViewCell!
    var newNumber: TextFieldCell!
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change number"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrentNumberCell")
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
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
        
        if sections[section] == "Current number" {
            label.frame = CGRect.init(x: headerX, y: 11, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            firstHeader = label
        } else if sections[section] == "New number" {
            label.frame = CGRect.init(x: headerX, y: 11, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            secondHeader = label
        } else {
            label.frame = CGRect.init(x: headerX, y: -20, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        }
        
        label.text = sections[section] == "New number" ? "Set number" : " "
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[0] == "New number" {
            if section == 0 {
                return 45
            } else {
                return 15
            }
        } else {
            return 15
        }
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewNumberCell", for: indexPath) as? TextFieldCell {
            if sections[indexPath.section] == "New number" {
                cell.textField.placeholder = "e.g. +441234567890"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.clearButtonMode = .whileEditing
                cell.selectionStyle = .none
                newNumber = cell
                return cell
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
        
        if Auth.auth().currentUser?.phoneNumber != nil {
            if sections[indexPath.section] == "Current number" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentNumberCell", for: indexPath)
                cell.textLabel?.text = Auth.auth().currentUser?.phoneNumber
                cell.selectionStyle = .none
                cell.imageView?.image = UIImage(systemName: "phone.fill")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 22)
                cell.textLabel?.textColor = .darkGray
                cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
                currentNumber = cell
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set editing style for each cell
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
       if sections[indexPath.section] == "Current number" {
           return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Delete number", message: "Are you sure you want to delete your phone number?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
                Auth.auth().currentUser?.unlink(fromProvider: PhoneAuthProviderID) { _, error in
                    guard error == nil else {
                        self?.showAlert(title: "Remove number failed", message: error!.localizedDescription)
                        return
                    }
                    self?.updateRows()
                    self?.reference.child(user).child("phoneNumber").removeValue()
                }
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        guard let phoneNumber = newNumber.textField.text else { return }
        
        if isNumberValid(phoneNumber) {
            saveNumber(number: phoneNumber)
            newNumber.textField.text = nil
        } else {
            showAlert(title: "Error", message: "Invalid number format")
        }
    }
    
    // add "done" button to numeric keyboard
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToKeyboard()
        updateRows()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // check phone number format
    func isNumberValid(_ number: String) -> Bool {
        let phoneRegex = #"^\+[0-9]{6,14}[0-9]$"#
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: number)
    }
    
    // update table view rows
    func updateRows() {
        let indexSet = IndexSet(integer: 0)
        
        if Auth.auth().currentUser?.phoneNumber != nil && sections.count == 2 {
            sections = ["Current number", "New number", "Button"]
            tableView.insertSections(indexSet, with: .fade)
            updateHeader(after: .add)
        } else if Auth.auth().currentUser?.phoneNumber == nil && sections.count == 3 {
            sections = ["New number", "Button"]
            tableView.deleteSections(indexSet, with: .fade)
            updateHeader(after: .delete)
        }
    }
    
    // update table view header
    func updateHeader(after: NumberAction) {
        let headerX = view.readableContentGuide.layoutFrame.minX
        
        tableView.beginUpdates()
        
        if after == .add {
            UIView.transition(with: secondHeader!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.secondHeader?.text = "New number"
                self.secondHeader?.frame = CGRect.init(x: headerX, y: -20, width: self.secondHeader.frame.width, height: self.secondHeader.frame.height)
            })
            
        } else {
            UIView.transition(with: secondHeader!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.secondHeader?.text = "Set number"
                self.secondHeader?.frame = CGRect.init(x: headerX, y: 11, width: self.secondHeader.frame.width, height: self.secondHeader.frame.height)
            })
        }

        tableView.endUpdates()
    }
    
    // set alert for correct/incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // update phone number cell
    func updateNumberCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        currentNumber.textLabel?.text = Auth.auth().currentUser?.phoneNumber
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // set "done" button for numeric keyboard
    func addDoneButtonToKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        let items = [spacer, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        newNumber.textField.inputAccessoryView = doneToolbar
    }
    
    // set action for tapped "done" button
    @objc func doneTapped() {
        newNumber.textField.resignFirstResponder()
    }
    
    // add current number to table view cell
    func setCurrentNumber() {
        let indexSet = IndexSet(integer: 0)
        
        if Auth.auth().currentUser?.phoneNumber != nil {
            sections = ["Current number", "New number", "Button"]
            tableView.insertSections(indexSet, with: .fade)
            updateHeader(after: .add)
        }
    }
    
    // save number to Firebase Authentication
    func saveNumber(number: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { [weak self] verificationID, error in
            
            guard let user = Auth.auth().currentUser?.uid else { return }

            guard error == nil else {
                self?.showAlert(title: "Verification failed", message: error!.localizedDescription)
                return
            }
            
            let ac = UIAlertController(title: "Verification", message: "Enter SMS code to authenticate", preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: ac.textFields![0].text!)
                
                Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { error in
                    guard error == nil else {
                        self?.showAlert(title: "Verification failed", message: "Invalid text code has been entered")
                        return
                    }
                    
                    if self?.sections.count == 2 {
                        self?.setCurrentNumber()
                        self?.updateNumberCell()
                    } else {
                        self?.updateNumberCell()
                    }
                    
                    self?.reference.child(user).child("phoneNumber").setValue(number)
                })
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true)
        }
    }
}
