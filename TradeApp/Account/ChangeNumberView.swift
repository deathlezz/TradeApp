//
//  ChangeNumberView.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import UIKit

enum NumberAction {
    case add
    case delete
}

class ChangeNumberView: UITableViewController {
    
    var sections = ["New number", "Button"]
    
    var oldNumber: UITableViewCell!
    var newNumber: TextFieldCell!
    
    var mail: String!
    var currentNumber: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change number"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrentNumberCell")
        
        DispatchQueue.global().async { [weak self] in
            self?.loadCurrentNumber()
            
            DispatchQueue.main.async {
                self?.setCurrentNumber()
            }
        }
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set header title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case "New number":
            if currentNumber != nil {
                return sections[section]
            } else {
                return "Set number"
            }
        default:
            return " "
        }
    }
    
    // set number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewNumberCell", for: indexPath) as? TextFieldCell {
            if sections[indexPath.section] == "New number" {
                cell.textField.placeholder = "e.g. 1234567890"
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
                cell.selectionStyle = .none
                return cell
            }
        }
        
        if currentNumber != nil {
            if sections[indexPath.section] == "Current number" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentNumberCell", for: indexPath)
                cell.textLabel?.text = "\(currentNumber!)"
                cell.selectionStyle = .none
                cell.imageView?.image = UIImage(systemName: "phone.fill")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 22)
                cell.textLabel?.textColor = .darkGray
                cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
                oldNumber = cell
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        
        if isNumberValid() && sections.count == 2 {
            Storage.shared.users[index].phoneNumber = Int(newNumber.textField.text!)
            currentNumber = Int(newNumber.textField.text!)
            newNumber.textField.text = nil
            updateRows()
        } else if isNumberValid() && sections.count == 3 {
            Storage.shared.users[index].phoneNumber = Int(newNumber.textField.text!)
            currentNumber = Int(newNumber.textField.text!)
            newNumber.textField.text = nil
            updateNumberCell()
        } else if newNumber.textField.text == "" && sections.count == 3 {
            Storage.shared.users[index].phoneNumber = Int(newNumber.textField.text!)
            newNumber.textField.text = nil
            currentNumber = nil
            updateRows()
        } else {
            showAlert(title: "Error", message: "Invalid number format")
        }
    }
    
    // set header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section] == "Current number" {
            return 10
        }
        return 30
    }
    
    // add "done" button to numeric keyboard
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToKeyboard()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // check phone number format
    func isNumberValid() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: newNumber.textField.text)
    }
    
    // load user's current phone number
    func loadCurrentNumber() {
        guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        currentNumber = Storage.shared.users[index].phoneNumber
    }
    
    // update table view rows
    func updateRows() {
        let indexSet = IndexSet(integer: 0)
        
        if currentNumber != nil {
            sections = ["Current number", "New number", "Button"]
            tableView.insertSections(indexSet, with: .automatic)
            updateHeader(after: .add)
        } else {
            sections = ["New number", "Button"]
            tableView.deleteSections(indexSet, with: .automatic)
            updateHeader(after: .delete)
        }
    }
    
    // update table view header
    func updateHeader(after: NumberAction) {
        tableView.beginUpdates()
        
        if after == .add {
            tableView.headerView(forSection: 1)?.textLabel?.text = "New number"
            tableView.headerView(forSection: 1)?.textLabel?.sizeToFit()
        } else {
            tableView.headerView(forSection: 0)?.textLabel?.text = "Set number"
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
        oldNumber.textLabel?.text = String(currentNumber)
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
        
        if currentNumber != nil {
            sections = ["Current number", "New number", "Button"]
            tableView.insertSections(indexSet, with: .automatic)
            updateHeader(after: .add)
        }
    }
}
