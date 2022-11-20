//
//  SearchHistoryTableView.swift
//  TradeApp
//
//  Created by deathlezz on 18/11/2022.
//

import UIKit

class SearchTableView: UITableViewController {
    
    var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: (navigationController?.navigationBar.frame.width)!, height: 30))
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Find something for yourself"
        textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
        textField.returnKeyType = .search
        navigationItem.titleView = textField
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        recentlySearched.count == 0 ? nil : "Recently searched"
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlySearched.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = recentlySearched[indexPath.row]
        return cell
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.text = recentlySearched[indexPath.row]
        returnTapped()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped() {
        if !textField.text!.isEmpty {
            filteredItems.removeAll()

            for item in items {
                if item.title.lowercased().contains(textField.text!.lowercased()) {
                    filteredItems.append(item)
                }
            }

            if !recentlySearched.contains(textField.text!) {
                let indexPath = IndexPath(row: 0, section: 0)
                recentlySearched.insert(textField.text!, at: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            isFilterApplied = true

        } else {
            filteredItems = recentlyAdded
            isFilterApplied = false
        }
        
        textField.text = ""
        textField.resignFirstResponder()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            recentlySearched.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // start editing textfield after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // finish editing texfield after view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
