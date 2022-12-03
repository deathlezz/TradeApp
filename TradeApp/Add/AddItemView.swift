//
//  AddItemView.swift
//  TradeApp
//
//  Created by deathlezz on 01/12/2022.
//

import UIKit

class PhotosView: UICollectionView {

    override func numberOfItems(inSection section: Int) -> Int {
        return 8
    }
    
    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        guard let cell = dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotosCell else {
            fatalError("Unable to dequeue photosCell")
        }
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
}

class AddItemView: UITableViewController {
    
    var textFieldCells = [TextFieldCell]()
    var textViewCell: TextViewCell!
    
    let sectionTitles = ["Photos", "Title", "Price", "Category", "Location", "Description", "Button"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        title = "Add"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
    }

    // set number of rows in section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 6 {
            return " "
        } else {
            return sectionTitles[section]
        }
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell {
            
            switch sectionTitles[indexPath.section] {
            case "Title":
                cell.textField.placeholder = "None"
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                textFieldCells.append(cell)
                return cell
            case "Price":
                cell.textField.placeholder = "None"
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.keyboardType = .numberPad
                textFieldCells.append(cell)
                return cell
            case "Category":
                cell.textField.placeholder = "None"
                cell.textField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                textFieldCells.append(cell)
                return cell
            case "Location":
                cell.textField.placeholder = "None"
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                textFieldCells.append(cell)
                return cell
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as? TextViewCell {
            if sectionTitles[indexPath.section] == "Description" {
                cell.textView.layer.cornerRadius = 5
                cell.textView.layer.borderWidth = 0.1
                cell.textView.layer.borderColor = UIColor.darkGray.cgColor
                textViewCell = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sectionTitles[indexPath.section] == "Button" {
                cell.submitButton.setTitle("Submit", for: .normal)
                return cell
            }
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosCell", for: indexPath) as? GalleryCell {
            if sectionTitles[indexPath.section] == "Photos" {
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for clear button
    @objc func clearTapped() {
        for cell in textFieldCells {
            cell.textField.text = nil
        }
        
        textViewCell.textView.text = nil
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
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
        
        textFieldCells[1].textField.inputAccessoryView = doneToolbar
        textViewCell.textView.inputAccessoryView = doneToolbar
    }

    // set action for "done" button
    @objc func doneTapped() {
        if textFieldCells[1].textField.isEditing {
            textFieldCells[1].textField.resignFirstResponder()
        } else {
            textViewCell.textView.resignFirstResponder()
        }
    }
    
    // add "done" button after view appeard
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDoneButtonToKeyboard()
    }

}
