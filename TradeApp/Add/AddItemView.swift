//
//  AddItemView.swift
//  TradeApp
//
//  Created by deathlezz on 01/12/2022.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseStorage

enum AlertType {
    case emptyField
    case cityError
    case success
    case edit
}

enum ActionType {
    case edit
}

class AddItemView: UITableViewController, ImagePicker, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var index: Int!
    var action: ActionType!

    var loggedUser: String!
    var isEditMode: Bool!
    var isAdActive: Bool!
    
    var reference: DatabaseReference!
    
    var uploadedPhotos = [UIImage]()
    
    var item: Item?
    
    var textFieldCells = [TextFieldCell]()
    var textViewCell: TextViewCell?
    
    var images = [UIImage]()
    
    let categories = ["Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
    
    let sections = ["Photos", "Title", "Price", "Category", "Location", "Description", "Button"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reorderImages), name: NSNotification.Name("reorderImages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: NSNotification.Name("signOut"), object: nil)
        
        if isEditMode != nil {
            title = "Edit"
            loadImages()
        } else {
            title = "Add"
        }
        
        for _ in 0...7 {
            images.append(UIImage(systemName: "plus")!)
        }
        
    }

    // set number of rows in section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set footer as number of available characters to use in description
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 5 {
            return "Characters left: \(200 - (textViewCell?.textView.text.count ?? 0))"
        } else {
            return nil
        }
    }
    
    // set footer alignment
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.textAlignment = .right
        footer.textLabel?.font = .boldSystemFont(ofSize: 15)
        footer.textLabel?.textColor = .systemGray
    }
    
    // set section footer height
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 5 ? 30 : 0
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        
        if section == 0 {
            label.frame = CGRect.init(x: 20, y: 12, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else if section == 5 {
            label.frame = CGRect.init(x: 20, y: -19, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else {
            label.frame = CGRect.init(x: 20, y: -20, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        }
        
        label.text = section == 6 ? " " : sections[section]
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 45
        case 6:
            return 5
        default:
            return 15
        }
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as? CollectionTableViewCell {
            if sections[indexPath.section] == "Photos" {
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell {
            
            switch sections[indexPath.section] {
            case "Title":
                cell.textField.text = item?.title ?? ""
                cell.textField.placeholder = "e.g. iPhone 14 Pro"
                cell.selectionStyle = .none
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                textFieldCells.append(cell)
                return cell
            case "Price":
                cell.textField.text = item?.price.description ?? ""
                cell.textField.placeholder = "£"
                cell.selectionStyle = .none
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.keyboardType = .numberPad
                textFieldCells.append(cell)
                return cell
            case "Category":
                cell.textField.text = item?.category ?? ""
                cell.textField.placeholder = "e.g. Electronics"
                cell.textField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                textFieldCells.append(cell)
                return cell
            case "Location":
                cell.textField.text = item?.location ?? ""
                cell.textField.placeholder = "e.g. City"
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
            if sections[indexPath.section] == "Description" {
                cell.selectionStyle = .none
                cell.textView.text = item?.description ?? ""
                cell.textView.layer.cornerRadius = 5
                cell.textView.layer.borderWidth = 0.1
                cell.textView.layer.borderColor = UIColor.darkGray.cgColor
                cell.textView.delegate = self
                textViewCell = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sections[indexPath.section] == "Button" {
                cell.selectionStyle = .none
                cell.submitButton.setTitle("Submit", for: .normal)
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                return cell
            }
        }

        return UITableViewCell()
    }
    
    // upload images on load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if title == "Add" && uploadedPhotos.count > 0 {
            NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": uploadedPhotos])
        }
    }
    
    // clear view before it disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if title == "Edit" {
            clearTapped()
        }
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.section] == "Category" {
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
    
    // load images and push them into CollectionView
    func loadImages() {
        DispatchQueue.global().async { [weak self] in

            let itemPhotos = self?.item?.photos.map {UIImage(data: $0!)!} ?? [UIImage]()
            
            for i in 0..<itemPhotos.count {
                self?.images[i] = itemPhotos[i]
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": self?.images ?? [UIImage]()])
            }
        }
    }
    
    // detect textView's text changes
    func textViewDidChange(_ textView: UITextView) {
        let charsUsed = textView.text.count
        
        if charsUsed == 201 {
            textView.text.removeLast()
            return
        }
        
        tableView.footerView(forSection: 5)?.textLabel?.text = "Characters left: \(200 - charsUsed)"
    }
    
    // set action for clear button
    @objc func clearTapped() {
        for cell in textFieldCells {
            cell.textField.text = nil
        }
        
        textViewCell?.textView.text = nil
        tableView.footerView(forSection: 5)?.textLabel?.text = "Characters left: 200"
        images.removeAll()
        uploadedPhotos.removeAll()
        
        for _ in 0...7 {
            images.append(UIImage(systemName: "plus")!)
        }

        NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": images])
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
        textViewCell?.textView.inputAccessoryView = doneToolbar
    }

    // set action for "done" button
    @objc func doneTapped() {
        if textFieldCells[1].textField.isEditing {
            textFieldCells[1].textField.resignFirstResponder()
        } else {
            textViewCell?.textView.resignFirstResponder()
        }
    }
    
    // add "done" button after view appeard
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDoneButtonToKeyboard()
    }
    
    // set action for submit button
    @objc func submitTapped(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        let photos = images.filter {$0 != UIImage(systemName: "plus")}.map {$0.pngData()}
            
        guard let title = textFieldCells[0].textField.text else { return }
        guard let price = textFieldCells[1].textField.text else { return }
        guard let category = textFieldCells[2].textField.text else { return }
        guard let location = textFieldCells[3].textField.text?.capitalized else { return }
        guard let description = textViewCell?.textView.text else { return }
        
        Utilities.isCityValid(location) { [weak self] valid in
            if !photos.isEmpty && !title.isEmpty && !price.isEmpty && !category.isEmpty && !location.isEmpty && !description.isEmpty {
                
                if valid {
                    Utilities.forwardGeocoding(address: location) { (lat, long) in
                        
                        if self?.isEditMode != nil {
                            guard let userIndex = AppStorage.shared.users.firstIndex(where: {$0.mail == self?.loggedUser}) else { return }
                            
                            // edit active item
                            if self?.isAdActive == true {
                                guard let itemIndex = AppStorage.shared.users[userIndex].activeItems.firstIndex(where: {$0?.id == self?.item?.id}) else { return }
                                let newItem = Item(photos: photos, title: title, price: Int(price)!, category: category, location: location, description: description, date: Date(), views: 0, saved: 0, lat: lat, long: long, id: (self?.item?.id)!)
                                AppStorage.shared.users[userIndex].activeItems[itemIndex] = newItem
                                
                                self?.uploadImages(images: photos, itemID: newItem.id) { [weak self] urls in
                                    guard let mail = self?.loggedUser.replacingOccurrences(of: ".", with: "_") else { return }
                                    self?.saveItem(user: mail, item: newItem, urls: urls)
                                }

                                NotificationCenter.default.post(name: NSNotification.Name("reloadActiveAds"), object: nil)
                                sender.isUserInteractionEnabled = true
                                self?.showAlert(.edit)
                                
                            } else {
                                // edit ended item
                                guard let itemIndex = AppStorage.shared.users[userIndex].endedItems.firstIndex(where: {$0?.id == self?.item?.id}) else { return }
                                let newItem = Item(photos: photos, title: title, price: Int(price)!, category: category, location: location, description: description, date: Date(), views: 0, saved: 0, lat: lat, long: long, id: (self?.item?.id)!)
                                AppStorage.shared.users[userIndex].endedItems[itemIndex] = newItem
                                
                                self?.uploadImages(images: photos, itemID: newItem.id) { [weak self] urls in
                                    guard let mail = self?.loggedUser.replacingOccurrences(of: ".", with: "_") else { return }
                                    self?.saveItem(user: mail, item: newItem, urls: urls)
                                }
                                
                                NotificationCenter.default.post(name: NSNotification.Name("reloadEndedAds"), object: nil)
                                sender.isUserInteractionEnabled = true
                                self?.showAlert(.edit)
                            }
                            
                        } else {
                            guard let userIndex = AppStorage.shared.users.firstIndex(where: {$0.mail == self?.loggedUser}) else { return }
                            
                            let newItem = Item(photos: photos, title: title, price: Int(price)!, category: category, location: location, description: description, date: Date(), views: 0, saved: 0, lat: lat, long: long, id: (self?.itemID())!)
                            AppStorage.shared.users[userIndex].activeItems.append(newItem)
                            AppStorage.shared.items.append(newItem)
                            
                            self?.uploadImages(images: photos, itemID: newItem.id) { [weak self] urls in
                                guard let mail = self?.loggedUser.replacingOccurrences(of: ".", with: "_") else { return }
                                self?.saveItem(user: mail, item: newItem, urls: urls)
                            }
                            
                            sender.isUserInteractionEnabled = true
                            self?.showAlert(.success)
                        }
                    }
                    
                } else {
                    sender.isUserInteractionEnabled = true
                    self?.showAlert(.cityError)
                }
                
            } else {
                sender.isUserInteractionEnabled = true
                self?.showAlert(.emptyField)
            }
        }
    }
    
    // show alert if at least one field is empty
    func showAlert(_ type: AlertType) {
        if type == .emptyField {
            let ac = UIAlertController(title: "Field empty", message: "Fill all text fields to continue.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        } else if type == .cityError {
            let ac = UIAlertController(title: "Invalid city name", message: "Enter valid city name to continue.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        } else if type == .edit {
            let ac = UIAlertController(title: "Item edited successfully", message: "Changes will be visible soon", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.clearTapped()
                self?.navigationController?.popViewController(animated: true)
            })
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
            let ac = UIAlertController(title: "Select image source", message: nil, preferredStyle: .actionSheet)
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

        if action == .edit {
            images[index] = image
        } else {
            for i in 0..<images.count {
                if images[i] == UIImage(systemName: "plus") {
                    images[i] = image
                    break
                }
            }
            
        }
        
        uploadedPhotos = images
        
        action = nil
        index = nil
        
        NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": images])
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)

        dismiss(animated: true)
    }
    
    // edit photo alert
    func editPhoto() {
        let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Change photo", style: .default) { [weak self] _ in
            self?.action = .edit
            self?.addNewPhoto()
        })
        
        ac.addAction(UIAlertAction(title: "Rotate photo", style: .default) { [weak self] _ in
            self?.rotatePhoto()
        })
        
        if index != 0 {
            ac.addAction(UIAlertAction(title: "Set as first", style: .default) { [weak self] _ in
                self?.setAsFirst()
            })
        }
        
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
        
        NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": images])
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    // change indexPath
    func pushIndex(indexPath: Int) {
        index = indexPath
    }
    
    // rotate photo by 90 degrees using Core Image
    func rotatePhoto() {
        let photo = images[index]
        images[index] = photo.rotate(radians: -.pi / 2)!
        
        NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": images])
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    // swap current image with the first one
    func setAsFirst() {
        (images[0], images[index]) = (images[index], images[0])
        NotificationCenter.default.post(name: NSNotification.Name("loadImages"), object: nil, userInfo: ["images": images])
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    // create unique item ID
    func itemID() -> Int {
        var uniqueID: Int!
        let usedIDs = AppStorage.shared.items.map {$0.id}
        let range = 10000000...99999999
        
        while uniqueID == nil {
            let random = range.randomElement()
            
            if !usedIDs.contains(random!) {
                uniqueID = random
                break
            }
        }
        return uniqueID
    }
    
    // sign out current user
    @objc func signOut() {
        navigationController?.popViewController(animated: true)
    }
    
    // get reordered images
    @objc func reorderImages(_ notification: NSNotification) {
        let reorderedImages = notification.userInfo?["images"] as! [UIImage]
        images = reorderedImages
    }
    
    // save images to Firebase Storage and return images URLs
    func uploadImages(images: [Data?], itemID: Int, completion: @escaping ([String: String]) -> Void) {
        var imagesURL = [String: String]()
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        for (index, image) in images.enumerated() {
            let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(mail).child("\(itemID)").child("image\(index)")
            
            guard let img = image else { return }
            
            storageRef.putData(img) { (metadata, error) in
                if metadata != nil {
                    storageRef.downloadURL() { (url, error) in
                
                        guard let urlString = url?.absoluteString else { return }
                        imagesURL["image\(index)"] = urlString
                        completion(imagesURL)
                    }
                }
            }
        }
    }
    
    // save item to Firebase Database
    func saveItem(user: String, item: Item, urls: [String: String]) {
        let newItem = item.toAnyObject(urls: urls)
        
        reference.child(user).child("activeItems").child("\(item.id)").setValue(newItem)
    }
    
    
}
