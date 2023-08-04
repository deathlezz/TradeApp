//
//  DetailViewController.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import UIKit
import CoreData
import Firebase
import MessageKit

enum SaveAction {
    case save
    case remove
}

class DetailView: UITableViewController, Index, Coordinates {

    var loggedUser: String!
    
    var savedItems = [Item]()
    
    var messageTextField: UITextField!
    
    var actionButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var removeButton: UIBarButtonItem!
    
    var messageSent = false
    
    var phone: Int!
    var views: Int!
    
    var latitude: Double!
    var longitude: Double!
    
    var reference: DatabaseReference!
    
    var item: Item!
    let sectionTitles = ["Image", "Title", "Tags", "Description", "Location", "Views"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = false
        navigationItem.backButtonTitle = " "
        navigationController?.hidesBarsOnSwipe = false
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        saveButton = UIBarButtonItem(image: .init(systemName: "heart"), style: .plain, target: self, action: #selector(saveTapped))
        
        removeButton = UIBarButtonItem(image: .init(systemName: "heart.fill"), style: .plain, target: self, action: #selector(removeTapped))
        
        navigationItem.rightBarButtonItems = [saveButton, actionButton]
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 83, right: 0)
        
        navigationController?.toolbar.layer.position.y = (self.tabBarController?.tabBar.layer.position.y)! - 17
        
        loggedUser = Utilities.loadUser()
        savedItems = Utilities.loadItems()
        checkForMessage()
        loadPhoneNumber()
        isSaved()
        increaseViews()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionTitles[section] == "Image" || sectionTitles[section] == "Title" {
            return nil
        } else if sectionTitles[section] == "Views" {
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
        switch sectionTitles[indexPath.section] {
        case "Image":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "detailCollectionView") as? DetailViewCell {
                cell.imgs = item.photos.map {UIImage(data: $0!)}
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
            
        case "Title":
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubText", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = "£\(item.price)"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 30)
            cell.isUserInteractionEnabled = false
            return cell
            
        case "Tags":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(item.category!) | \(item.location) | Added on \(item.date.toString(shortened: true))"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.isUserInteractionEnabled = false
            return cell
            
        case "Description":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
            cell.textLabel?.text = item.description
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.isUserInteractionEnabled = false
            return cell
            
        case "Location":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as? MapViewCell {
                cell.delegate = self
                cell.cityLabel.text = item.location
                cell.cityLabel.font = UIFont.systemFont(ofSize: 14)
                cell.cityLabel.numberOfLines = 0
                cell.distanceLabel.text = "--"
                cell.distanceLabel.font = UIFont.systemFont(ofSize: 14)
                cell.distanceLabel.numberOfLines = 0
                cell.mapView.layer.cornerRadius = 8
                cell.mapView.mapType = .standard
                cell.mapView.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
            
        case "Views":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
            cell.textLabel?.text = "Views: \(views ?? item.views!)"
            cell.backgroundColor = .systemGray6
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionTitles[indexPath.section] == "Location" {
            openMaps()
        }
    }
    
    // set action for save item button
    @objc func saveTapped() {
        savedItems.insert(item, at: 0)
        
        if savedItems.count > 50 {
            showAlert()
            savedItems.remove(at: 0)
        } else {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        }
        
        updateSaved(action: .save)
        Utilities.saveItem(item)
    }
    
    // set action for remove item button
    @objc func removeTapped() {
        guard let index = savedItems.firstIndex(where: {$0.id == item.id}) else { return }
        Utilities.removeItems([savedItems[index]])
        savedItems.remove(at: index)
        updateSaved(action: .remove)
        navigationItem.rightBarButtonItems = [saveButton, actionButton]
    }
    
    // set action for action button
    @objc func shareTapped() {
        messageTextField.resignFirstResponder()
        
        let title = item.title
        
        let vc = UIActivityViewController(activityItems: [title], applicationActivities: [])
        
        present(vc, animated: true)
    }
    
    // set location and map after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name("restoreMap"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name("pushLocation"), object: nil, userInfo: ["location": item.location])
    }
    
    // show tab bar and navigation bar before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
    }
    
    // show keyboard before view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard messageTextField != nil else { return }
        messageTextField.resignFirstResponder()
    }
    
    // show save alert
    func showAlert() {
        let ac = UIAlertController(title: "You can't save more items.", message: "You've already saved 50 items.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    // set action for call button
    @objc func callTapped() {
        guard let phone = phone else { return }
        
        let ac = UIAlertController(title: "Phone number", message: "\(phone)", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Phone call", style: .default) { _ in
            guard let url = URL(string: "telprompt://\(phone)"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Text message", style: .default) { _ in
            guard let url = URL(string: "sms://\(phone)"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // set action for message button
    @objc func messageTapped() {
        if messageSent {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ChatView") as? ChatView {
                vc.chatTitle = item.title
                vc.loggedUser = loggedUser
                vc.isPushedByChats = false
                vc.buyer = loggedUser
                vc.seller = item.owner
                vc.itemID = item.id
                navigationController?.present(vc, animated: true)
            }
        } else {
            addToolbarToKeyboard()
            messageTextField.becomeFirstResponder()
        }
    }

    // get current image index and push view controller
    func pushIndex(index: Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ItemView") as? ItemView {
            vc.currentImage = index
            vc.imgs = item.photos.map {UIImage(data: $0!)}
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // remove mapView after view disappeared
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: NSNotification.Name("removeMap"), object: nil)
        }
    }
    
    // push item coordinates
    func pushCoords(_ lat: Double, _ long: Double) {
        latitude = lat
        longitude = long
    }
    
    // open google maps or apple maps
    func openMaps() {
        guard let lat = latitude else { return }
        guard let long = longitude else { return }
        
        if messageTextField != nil {
            messageTextField.resignFirstResponder()
        }
        
        let appleMaps = URL(string: "maps://")!
        let googleMaps = URL(string: "comgooglemaps://")!
        
        if UIApplication.shared.canOpenURL(appleMaps) && UIApplication.shared.canOpenURL(googleMaps) {
            let ac = UIAlertController(title: "Choose a map provider", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Google Maps", style: .default) { _ in
                guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(lat),\(long)") else { return }
                UIApplication.shared.open(url)
            })
            ac.addAction(UIAlertAction(title: "Apple Maps", style: .default) { _ in
                guard let url = URL(string: "maps://?saddr=&daddr=\(lat),\(long)") else { return }
                UIApplication.shared.open(url)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else if UIApplication.shared.canOpenURL(appleMaps) {
            guard let url = URL(string: "maps://?saddr=&daddr=\(lat),\(long)") else { return }
            UIApplication.shared.open(url)
            
        } else if UIApplication.shared.canOpenURL(googleMaps) {
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(lat),\(long)") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    // define if item is saved or not
    func isSaved() {
        if savedItems.contains(where: {$0.id == item.id}) {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        } else {
            navigationItem.rightBarButtonItems = [saveButton, actionButton]
        }
    }
    
    // set toolbar
    func setToolbar() {
        let callFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 20, height: 50))
        let image = UIImage(systemName: "phone.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        callFrame.setImage(image, for: .normal)
        callFrame.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callFrame.backgroundColor = .white
        callFrame.layer.cornerRadius = 7
        callFrame.layer.borderColor = UIColor.lightGray.cgColor
        callFrame.layer.borderWidth = 0.2
        let callButton = UIBarButtonItem(customView: callFrame)
        
        let messageFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 20, height: 50))
        var message = UIImage()
        
        if messageSent {
            message = UIImage(systemName: "checkmark.message.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
        } else {
            message = UIImage(systemName: "ellipsis.message.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
        }
        
        messageFrame.setImage(message, for: .normal)
        messageFrame.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
        messageFrame.backgroundColor = .white
        messageFrame.layer.cornerRadius = 7
        messageFrame.layer.borderColor = UIColor.lightGray.cgColor
        messageFrame.layer.borderWidth = 0.2
        let messageButton = UIBarButtonItem(customView: messageFrame)
        
        if loggedUser == nil && phone == 0 {
            // show disabled message button only
            messageButton.customView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 50)
            messageButton.isEnabled = false
            callButton.isHidden = true
        } else if loggedUser == nil {
            // show call button and disabled message button
            messageButton.isEnabled = false
        } else if phone == 0 {
            // show message button only
            messageButton.customView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 50)
            callButton.isHidden = true
        }
        
        if loggedUser != nil {
            let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
            
//            if mail == item.owner {
//                messageButton.isEnabled = false
//            }
        }
        
        toolbarItems = [callButton, messageButton]
    }
    
    // load item's phone number
    func loadPhoneNumber() {
        let owner = item.owner
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("phoneNumber").observeSingleEvent(of: .value) { snapshot in
                if let number = snapshot.value as? Int {
                    self?.phone = number
                }
            }
        }
    }
    
    // increase number of views
    func increaseViews() {
        let owner = item.owner
        let itemID = item.id
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("activeItems").child("\(itemID)").child("views").observeSingleEvent(of: .value) { snapshot in
                if let views = snapshot.value as? Int {
                    
                    if self?.loggedUser == nil {
                        self?.reference.child(owner).child("activeItems").child("\(itemID)").child("views").setValue(views + 1)
                        self?.views = views + 1
                    } else {
                        self?.views = views
                    }
                    
                    DispatchQueue.main.async {
                        let indexSet = IndexSet(integer: 5)
                        self?.tableView.reloadSections(indexSet, with: .automatic)
                    }
                }
            }
        }
    }
    
    // update number of saved
    func updateSaved(action: SaveAction) {
        let owner = item.owner
        let itemID = item.id
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("activeItems").child("\(itemID)").child("saved").observeSingleEvent(of: .value) { snapshot in
                if let saved = snapshot.value as? Int {
                    if action == .save {
                        self?.reference.child(owner).child("activeItems").child("\(itemID)").child("saved").setValue(saved + 1)
                    } else {
                        self?.reference.child(owner).child("activeItems").child("\(itemID)").child("saved").setValue(saved - 1)
                    }
                }
            }
        }
    }
    
    // set keyboard toolbar
    func addToolbarToKeyboard() {
        let toolbar = UIToolbar(frame: CGRect.init(x: UIScreen.main.bounds.height, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(hideKeyboard))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let textField = UITextField(frame: CGRect.init(x: 0, y: 0, width: toolbar.bounds.width - 60, height: 30))
        textField.inputAccessoryView = toolbar
        textField.returnKeyType = .send
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Enter your message here"
        textField.inputAccessoryView = toolbar
        textField.addTarget(self, action: #selector(sendMessage), for: .primaryActionTriggered)
        messageTextField = textField
        view.addSubview(toolbar)
        let textFieldButton = UIBarButtonItem(customView: textField)

        let items = [backButton, spacer, textFieldButton]
        toolbar.items = items
        toolbar.sizeToFit()
    }
    
    // send message function
    @objc func sendMessage() {
        guard !messageTextField.text!.isEmpty else { return }
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        let sender = Sender(senderId: mail, displayName: mail.components(separatedBy: "@")[0])
        
        let newMessage = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text((messageTextField.text)!))
        
        let chat = [newMessage]
        let anyChat = chat.map {$0.toAnyObject()}
        
        DispatchQueue.global().async { [weak self] in
            guard let owner = self?.item.owner else { return }
            guard let itemID = self?.item.id else { return }
            
            self?.reference.child(owner).child("chats").child("\(itemID)").child(mail).setValue(anyChat)
            
            DispatchQueue.main.async {
                self?.messageSent = true
                self?.setToolbar()
                self?.messageTextField.resignFirstResponder()
            }
        }
    }
    
    // hide keyboard
    @objc func hideKeyboard() {
        messageTextField.resignFirstResponder()
        messageTextField.removeFromSuperview()
    }
    
    // check if message was sent
    func checkForMessage() {
        guard loggedUser != nil else {
            setToolbar()
            return
        }
        
        let mail = loggedUser.replacingOccurrences(of: ".", with: "_")
        
        DispatchQueue.global().async { [weak self] in
            guard let owner = self?.item.owner else { return }
            guard let itemID = self?.item.id else { return }
            
            self?.reference.child(owner).child("chats").child("\(itemID)").child(mail).observeSingleEvent(of: .value) { snapshot in
                if let _ = snapshot.value as? [[String: String]] {
                    self?.messageSent = true
                } else {
                    self?.messageSent = false
                }
                
                DispatchQueue.main.async {
                    self?.setToolbar()
                }
            }
        }
    }
    
}
