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
import FirebaseAuth

enum SaveAction {
    case save
    case remove
}

class DetailView: UITableViewController, Index, Coordinates {
    
    var savedItems = [Item]()
    
    var messageTextField: UITextField!
    
    var actionButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var removeButton: UIBarButtonItem!
    
    var messageSent = false
    static var isLoaded = false
    
    var phone: Int!
    var views: Int!
    
    var latitude: Double!
    var longitude: Double!
    
    var reference: DatabaseReference!
    var isOpenedByActiveAds = false
    var isOpenedByEndedAds = false
    var isAdActive: Bool!
    
    var item: Item!
    var images = [UIImage]()
    
    let sectionTitles = ["Image", "Title", "Tags", "Description", "Location", "Views"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = false
        navigationItem.backButtonTitle = " "
        navigationController?.hidesBarsOnSwipe = false
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Text")
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        if isAdActive {
            actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
            
            saveButton = UIBarButtonItem(image: .init(systemName: "heart"), style: .plain, target: self, action: #selector(saveTapped))
            
            removeButton = UIBarButtonItem(image: .init(systemName: "heart.fill"), style: .plain, target: self, action: #selector(removeTapped))
            
            navigationItem.rightBarButtonItems = [saveButton, actionButton]
            
            savedItems = Utilities.loadItems()
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 83, right: 0)
        
        navigationController?.toolbar.layer.position.y = (self.tabBarController?.tabBar.layer.position.y)! - 17
 
        DispatchQueue.global().async { [weak self] in
            self?.getData() { dict in
                guard let dict = dict else {
                    self?.showItemNotFoundAlert()
                    return
                }
                
                let item = self?.toItemModel(dict: dict)
                guard let urls = item?.photosURL else { return }
                
                self?.convertImages(urls: urls) { imgs in
                    self?.item = item
                    self?.item?.thumbnail = imgs[0]
                    self?.images = imgs
                    
                    self?.loadPhoneNumber {
                        self?.checkForMessage()
                        self?.isSaved()
                        self?.increaseViews()
                        DetailView.isLoaded = true
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name("updateImages"), object: nil, userInfo: ["images": imgs])
                            
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let _ = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") {
            if sectionTitles[section] == "Image" || sectionTitles[section] == "Title" {
                return nil
            } else if sectionTitles[section] == "Views" {
                return " "
            } else {
                return sectionTitles[section]
            }
        }
        
        return nil
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
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
            
        case "Title":
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SubText")
            
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubText")
            }
            
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
    
    // remove header text
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") {
            header.textLabel?.text = nil
        }
    }
    
    // remove cell text
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Text") {
            cell.textLabel?.text = nil
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SubText") {
            cell.textLabel?.text = nil
        }
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
        if messageTextField != nil {
            messageTextField.resignFirstResponder()
        }
        
        let customURL = "com.TradeApp://show/\(item.id)"
        guard let url = URL(string: customURL) else { return }
        
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        
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
        
        if isMovingFromParent {
            NotificationCenter.default.post(name: NSNotification.Name("removeImages"), object: nil)
            savedItems.removeAll()
            images.removeAll()
            phone = nil
            views = nil
            latitude = nil
            longitude = nil
        }
        
        guard messageTextField != nil else { return }
        messageTextField.text = nil
        messageTextField.resignFirstResponder()
    }
    
    // show save alert
    func showAlert() {
        let ac = UIAlertController(title: "You can't save more items.", message: "You've already saved 50 items.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    // show item not found alert
    func showItemNotFoundAlert() {
        guard let isAdActive = isAdActive else { return }
        let itemId = item.id
        
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Item not found", message: "Item is not available anymore", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if isAdActive {
                    AppStorage.shared.items.removeAll(where: {$0.id == itemId})
                    AppStorage.shared.filteredItems.removeAll(where: {$0.id == itemId})
                    AppStorage.shared.recentlyAdded.removeAll(where: {$0.id == itemId})
                }
                self?.navigationController?.popViewController(animated: true)
            })
            self?.present(ac, animated: true)
        }
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
                ChatView.buyer = Auth.auth().currentUser?.uid
                ChatView.seller = item.owner
                vc.itemId = String(item.id)
                present(vc, animated: true)
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
            vc.imgs = images
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // remove mapView after view disappeared
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            NotificationCenter.default.post(name: NSNotification.Name("removeMap"), object: nil)
            
            if isOpenedByActiveAds {
                NotificationCenter.default.post(name: NSNotification.Name("updateActiveAd"), object: item)
                isOpenedByActiveAds = false
            } else if isOpenedByEndedAds {
                NotificationCenter.default.post(name: NSNotification.Name("updateEndedAd"), object: item)
                isOpenedByEndedAds = false
            }

            item = nil
            DetailView.isLoaded = false
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
        guard isAdActive else { return }
        if savedItems.contains(where: {$0.id == item.id}) {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        } else {
            navigationItem.rightBarButtonItems = [saveButton, actionButton]
        }
    }
    
    // set toolbar
    func setToolbar() {
        let callFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2.25), height: 50))
        let image = UIImage(systemName: "phone.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        callFrame.setImage(image, for: .normal)
        callFrame.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callFrame.backgroundColor = .white
        callFrame.layer.cornerRadius = 7
        callFrame.layer.borderColor = UIColor.lightGray.cgColor
        callFrame.layer.borderWidth = 0.2
        let callButton = UIBarButtonItem(customView: callFrame)
        
        let messageFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2.25), height: 50))
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
        
        if Auth.auth().currentUser == nil && phone == nil {
            // show disabled message button only
            messageButton.customView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 50)
            messageButton.isEnabled = false
            callButton.isHidden = true
        } else if Auth.auth().currentUser == nil {
            // show call button and disabled message button
            messageButton.isEnabled = false
        } else if phone == nil {
            // show message button only
            messageButton.customView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 50)
            callButton.isHidden = true
        }
        
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.uid == item.owner {
                messageButton.isEnabled = false
            }
        }
        
        toolbarItems = [callButton, messageButton]
    }
    
    // load item's phone number
    func loadPhoneNumber(completion: @escaping () -> Void) {
        let owner = item.owner

        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("phoneNumber").observeSingleEvent(of: .value) { snapshot in
                if let number = snapshot.value as? String {
                    self?.phone = Int(number)
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // increase number of views
    func increaseViews() {
        let user = Auth.auth().currentUser?.uid
        let owner = item.owner
        let itemID = item.id
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("activeItems").child("\(itemID)").child("views").observeSingleEvent(of: .value) { snapshot in
                if let views = snapshot.value as? Int {
                    
                    if user != owner {
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
        let itemId = item.id
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(owner).child("activeItems").child("\(itemId)").child("saved").observeSingleEvent(of: .value) { snapshot in
                if let saved = snapshot.value as? Int {
                    if action == .save {
                        self?.reference.child(owner).child("activeItems").child("\(itemId)").child("saved").setValue(saved + 1)
                    } else {
                        self?.reference.child(owner).child("activeItems").child("\(itemId)").child("saved").setValue(saved - 1)
                    }
                } else {
                    self?.reference.child(owner).child("endedItems").child("\(itemId)").child("saved").observeSingleEvent(of: .value) { snapshot in
                        if let saved = snapshot.value as? Int {
                            if action == .remove {
                                self?.reference.child(owner).child("endedItems").child("\(itemId)").child("saved").setValue(saved - 1)
                            }
                        }
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
        
        guard let user = Auth.auth().currentUser?.uid else { return }
        let itemId = item.id
        let itemOwner = item.owner
        
        let sender = Sender(senderId: user, displayName: "")
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(itemOwner).child("chats").child("\(itemId)").child(user).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                
                var ownerMessageId = 0
                
                if snapshot.hasChildren() {
                    if let lastMessage = snapshot.value as? [String: [String: String]] {
                        ownerMessageId = Int((lastMessage.values.first?["messageId"])!)! + 1
                        
                        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                        
                        let ownerMessage = Message(sender: sender, messageId: "\(ownerMessageId)", sentDate: Date(), kind: .text((self?.messageTextField.text)!))
                        
                        self?.reference.child(itemOwner).child("chats").child("\(itemId)").child(user).child("messages").child("\(timestamp)").setValue(ownerMessage.toAnyObject())
                        self?.reference.child(itemOwner).child("chats").child("\(itemId)").child(user).child("read").setValue(false)
                    }
                } else {
                    let ownerMessage = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text((self?.messageTextField.text)!))
                    let ownerChat = Chat(messages: [ownerMessage], itemId: String(itemId), itemOwner: itemOwner, buyer: user)
                    self?.reference.child(itemOwner).child("chats").child("\(itemId)").child(user).setValue(ownerChat.toAnyObject())
                    self?.reference.child(itemOwner).child("chats").child("\(itemId)").child(user).child("read").setValue(false)
                }
                
                let buyerMessage = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text((self?.messageTextField.text)!))
                let buyerChat = Chat(messages: [buyerMessage], itemId: String(itemId), itemOwner: itemOwner, buyer: user)
                self?.reference.child(user).child("chats").child("\(itemId)").child(itemOwner).setValue(buyerChat.toAnyObject())
                self?.reference.child(user).child("chats").child("\(itemId)").child(itemOwner).child("read").setValue(true)
                
                DispatchQueue.main.async {
                    self?.messageSent = true
                    self?.setToolbar()
                    self?.messageTextField.resignFirstResponder()
                }
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
        guard let user = Auth.auth().currentUser?.uid else {
            setToolbar()
            return
        }
        
        guard user != item.owner else {
            setToolbar()
            return
        }
        
        let owner = item.owner
        let itemId = item.id
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").child("\(itemId)").child(owner).child("messages").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChildren() {
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
    
    // convert URLs into images
    func convertImages(urls: [String], completion: @escaping ([UIImage]) -> Void) {
        let links = urls.map {URL(string: $0)!}
        
        var imagesDict = [String: UIImage]()

        DispatchQueue.global().async {
            for (index, url) in links.enumerated() {
                let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data) ?? UIImage()
                            imagesDict["image\(index)"] = image
                            
                            guard imagesDict.count == links.count else { return }
                            let sorted = imagesDict.sorted {$0.key < $1.key}
                            let images = Array(sorted.map {$0.value})
                            completion(images)
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    // download item data from Firebase
    func getData(completion: @escaping ([String: Any]?) -> Void) {
        guard let isAdActive = isAdActive else { return }
        let owner = item.owner
        let itemId = item.id
        
        DispatchQueue.global().async { [weak self] in
            if isAdActive {
                self?.reference.child(owner).child("activeItems").child("\(itemId)").observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? [String: Any] {
                        completion(value)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                self?.reference.child(owner).child("endedItems").child("\(itemId)").observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? [String: Any] {
                        completion(value)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // convert dictionary to Item() model
    func toItemModel(dict: [String: Any]) -> Item {
        let photosURL = dict["photosURL"] as? [String]
        let title = dict["title"] as? String
        let price = dict["price"] as? Int
        let category = dict["category"] as? String
        let location = dict["location"] as? String
        let description = dict["description"] as? String
        let date = dict["date"] as? String
        let views = dict["views"] as? Int
        let saved = dict["saved"] as? Int
        let lat = dict["lat"] as? Double
        let long = dict["long"] as? Double
        let id = dict["id"] as? Int
        let owner = dict["owner"] as? String
        
        let model = Item(photosURL: photosURL!, title: title!, price: price!, category: category!, location: location!, description: description!, date: date!.toDate(), views: views!, saved: saved!, lat: lat!, long: long!, id: id!, owner: owner!)
        
        if let index = AppStorage.shared.items.firstIndex(where: {$0.id == id}) {
            AppStorage.shared.items[index] = model
        }
        if let index = AppStorage.shared.filteredItems.firstIndex(where: {$0.id == id}) {
            AppStorage.shared.filteredItems[index] = model
        }
        if let index = AppStorage.shared.recentlyAdded.firstIndex(where: {$0.id == id}) {
            AppStorage.shared.recentlyAdded[index] = model
        }
        
        return model
    }
    
}
