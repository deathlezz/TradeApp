//
//  ChangeNumberView.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import UIKit

class ChangeNumberView: UITableViewController {
    
    let sections = ["Current number", "New number", "Button"]
    
    var cells = [TextFieldCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change number"
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as? TextFieldCell {
            if sections[indexPath.section] == "Current number" {
                cell.textField.placeholder = "e.g. 1234567890"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.clearButtonMode = .whileEditing
                cell.selectionStyle = .none
                cells.append(cell)
                return cell
            } else if sections[indexPath.section] == "New number" {
                cell.textField.placeholder = "e.g. 1234567890"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.textField.clearButtonMode = .whileEditing
                cell.selectionStyle = .none
                cells.append(cell)
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
        
        return UITableViewCell()
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        if isNumberValid() {
            print("number valid")
        } else {
            print("number invalid")
        }
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // check phone number format
    func isNumberValid() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: cells[1].textField.text)
    }
    
    // set alert for incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    

}
