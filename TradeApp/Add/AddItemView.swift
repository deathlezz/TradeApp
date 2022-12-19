//
//  AddItemView.swift
//  TradeApp
//
//  Created by deathlezz on 01/12/2022.
//

import UIKit

enum AlertType {
    case error
    case success
}

enum ActionType {
    case edit
}

class AddItemView: UITableViewController, ImagePicker, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var index: Int!
    var action: ActionType!
    
    var textFieldCells = [TextFieldCell]()
    var textViewCell: TextViewCell!
    
    let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
    
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as? CollectionTableViewCell {
            if sectionTitles[indexPath.section] == "Photos" {
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell {
            
            switch sectionTitles[indexPath.section] {
            case "Title":
                cell.textField.placeholder = "None"
                cell.selectionStyle = .none
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                textFieldCells.append(cell)
                return cell
            case "Price":
                cell.textField.placeholder = "None"
                cell.selectionStyle = .none
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
                cell.selectionStyle = .none
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
                cell.selectionStyle = .none
                cell.textView.layer.cornerRadius = 5
                cell.textView.layer.borderWidth = 0.1
                cell.textView.layer.borderColor = UIColor.darkGray.cgColor
                textViewCell = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sectionTitles[indexPath.section] == "Button" {
                cell.selectionStyle = .none
                cell.submitButton.setTitle("Submit", for: .normal)
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                return cell
            }
        }

        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionTitles[indexPath.section] == "Category" {
            let ac = UIAlertController(title: "Categories", message: nil, preferredStyle: .actionSheet)
            for category in categories {
                ac.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                    self?.textFieldCells[2].textField.text = category
                })
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    // set action for clear button
    @objc func clearTapped() {
        for cell in textFieldCells {
            cell.textField.text = nil
        }
        
        textViewCell.textView.text = nil
        
        for i in 0...7 {
            images[i] = UIImage(systemName: "plus")!
        }

        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
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
    
    // set action for submit button
    @objc func submitTapped() {
        let photos = images.map {$0.pngData()}
        let title = textFieldCells[0].textField.text
        let price = textFieldCells[1].textField.text
        let category = textFieldCells[2].textField.text
        let location = textFieldCells[3].textField.text
        let description = textViewCell.textView.text
        
        if !photos.isEmpty && !title!.isEmpty && !price!.isEmpty && !category!.isEmpty && !location!.isEmpty && !description!.isEmpty {
            let newItem = Item(photos: photos, title: title!, price: Int(price!)!, category: category!, location: location!, description: description!, date: Date())
            items.append(newItem)
            recentlyAdded.append(newItem)
            showAlert(.success)
        } else {
            showAlert(.error)
        }
    }
    
    // show alert if at least one field is empty
    func showAlert(_ type: AlertType) {
        if type == .error {
            let ac = UIAlertController(title: "Field empty", message: "Fill all text fields to continue.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Item added successfully", message: "Your item will be visible soon", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                self?.clearTapped()
                self?.tabBarController?.selectedIndex = 0
            })
            
            present(ac, animated: true)
        }
    }
    
    // show source type alert
    func addNewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let ac = UIAlertController(title: "Source", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.showPicker(fromCamera: true)
            })
            
            ac.addAction(UIAlertAction(title: "Photos", style: .default) { [weak self] _ in
                self?.showPicker(fromCamera: false)
            })
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else {
            showPicker(fromCamera: false)
        }
    }
    
    // show image picker
    func showPicker(fromCamera: Bool) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        if fromCamera {
            picker.sourceType = .camera
        }
        
        present(picker, animated: true)
    }
    
    // set chosen image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        if action == .edit {
            images[index] = image
        } else {
            for i in 0...images.count {
                if images[i] == UIImage(systemName: "plus") {
                    images[i] = image
                    break
                }
            }
        }
        
        action = nil
        index = nil
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    // edit photo alert
    func editPhoto() {
        let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Change photo", style: .default) { [weak self] _ in
            self?.action = .edit
            self?.addNewPhoto()
        })
        ac.addAction(UIAlertAction(title: "Delete photo", style: .destructive) { [weak self] _ in
            self?.action = .edit
            self?.deletePhoto()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // remove photo
    func deletePhoto() {
        images[index] = UIImage(systemName: "plus")!
        let plusImages = images.filter {$0 == UIImage(systemName: "plus")}
        images = images.filter {$0 != UIImage(systemName: "plus")}
        images += plusImages
        action = nil
        index = nil
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    // change indexPath
    func pushIndex(indexPath: Int) {
        index = indexPath
    }
    
}
