//
//  EndedAdsView.swift
//  TradeApp
//
//  Created by deathlezz on 30/03/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class EndedAdsView: UITableViewController {
    
    var emptyArrayView: UIView!
    
    var header: UILabel!
    
    var endedAds = [Item]()
    
    var reference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ended"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorInset.left = 17
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserAds), name: NSNotification.Name("reloadEndedAds"), object: nil)
        
        addEmptyArrayView()
        loadUserAds()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23
    }
    
    // set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return endedAds.count
    }
    
    // set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / 1.9
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let headerX = view.readableContentGuide.layoutFrame.minX
            
        let label = UILabel()
        label.frame = CGRect.init(x: headerX, y: -13, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = endedAds.count == 1 ? "Found 1 ad" : "Found \(endedAds.count) ads"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .gray
        
        header = label
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "endedAdCell", for: indexPath) as? AdCell {
            cell.thumbnail.image = endedAds[indexPath.row].thumbnail
            cell.thumbnail.layer.cornerRadius = 7
            cell.title.text = endedAds[indexPath.row].title
            cell.price.text = "£\(endedAds[indexPath.row].price)"
            cell.availability.text = setExpiryDate(endedAds[indexPath.row].date)
            cell.views.setTitle(endedAds[indexPath.row].views?.description, for: .normal)
            cell.views.isUserInteractionEnabled = false
            cell.saved.setTitle(endedAds[indexPath.row].saved?.description, for: .normal)
            cell.saved.isUserInteractionEnabled = false
            cell.stateButton.layer.borderWidth = 1.5
            cell.stateButton.layer.borderColor = UIColor.darkGray.cgColor
            cell.stateButton.titleLabel?.textColor = .darkGray
            cell.stateButton.layer.cornerRadius = 7
            cell.stateButton.tag = endedAds[indexPath.row].id
            cell.stateButton.addTarget(self, action: #selector(stateTapped), for: .touchUpInside)
            cell.editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
            cell.editButton.tag = endedAds[indexPath.row].id
            cell.separatorInset = .zero
            return cell
        }
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = endedAds[indexPath.row]
            vc.images = [(endedAds[indexPath.row].thumbnail)!]
            vc.hidesBottomBarWhenPushed = true
            vc.toolbarItems = []
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = endedAds[indexPath.row]
            
            let ac = UIAlertController(title: "Delete ad", message: "Are you sure, you want to delete this ad?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                AppStorage.shared.items.removeAll(where: {$0.id == item.id})
                AppStorage.shared.filteredItems.removeAll(where: {$0.id == item.id})
                
                self?.deleteItem(item: item)
                self?.endedAds.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                self?.updateHeader()
                self?.isArrayEmpty()
            })
            present(ac, animated: true)
        }
    }
    
    // set hide/show bars on scroll
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // set action for tapped edit button
    @objc func editTapped(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddItemView") as? AddItemView {
            guard let item = endedAds.first(where: {$0.id == sender.tag}) else { return }
            vc.isEditMode = true
            vc.isAdActive = false
            vc.item = item
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // update table view header
    func updateHeader() {
        tableView.beginUpdates()
        header.text = endedAds.count == 1 ? "Found 1 ad" : "Found \(endedAds.count) ads"
        tableView.endUpdates()
    }
    
    // load user's ended ads
    @objc func loadUserAds() {
        DispatchQueue.global().async { [weak self] in
            self?.getEndedAds() { dict in
                self?.endedAds = self?.toItemModel(dict: dict) ?? [Item]()
                
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // hide toolbar before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isArrayEmpty()
        navigationController?.isToolbarHidden = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    // remove stored data
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endedAds.removeAll()
    }
    
    // set item expiry date
    func setExpiryDate(_ expiryDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMMM d"
        let formattedExpiryDate = dateFormatter.string(from: expiryDate)
        return "expired \(formattedExpiryDate)"
    }
    
    // set action for tapped state button
    @objc func stateTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Activate ad", message: "Are you sure, you want to activate this ad?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Activate", style: .default) { [weak self] _ in
            self?.activateAd(sender)
        })
        present(ac, animated: true)
    }
    
    // activate the ad
    func activateAd(_ sender: UIButton) {
        guard let itemIndex = endedAds.firstIndex(where: {$0.id == sender.tag}) else { return }
        
        let date = Date().toString(shortened: false)
        moveItem(itemId: sender.tag, date: date)
        endedAds.remove(at: itemIndex)
        
        let indexPath = IndexPath(row: itemIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateHeader()
        isArrayEmpty()
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let safeArea = (navigationController?.navigationBar.frame.maxY)!
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - safeArea - 25, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .clear
        myView.addSubview(label)
        view.addSubview(myView)
        emptyArrayView = myView
    }
    
    // check if array is empty or not
    func isArrayEmpty() {
        if endedAds.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // move item from endedItems to activeItems folder in Firebase
    func moveItem(itemId: Int, date: String) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("endedItems").child("\(itemId)").observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    self?.reference.child(user).child("activeItems").child("\(itemId)").setValue(value)
                    self?.reference.child(user).child("activeItems").child("\(itemId)").child("date").setValue(date)
                    self?.reference.child(user).child("activeItems").child("\(itemId)").child("views").setValue(0)
                    self?.reference.child(user).child("activeItems").child("\(itemId)").child("saved").setValue(0)
                    self?.reference.child(user).child("endedItems").child("\(itemId)").removeValue()
                }
            }
        }
    }
    
    // delete item from Firebase
    func deleteItem(item: Item) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
//            for i in 0..<item.photosURL.count {
//                let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(user).child("\(item.id)").child("image\(i)")
//                storageRef.delete() { _ in }
//            }
//            
//            self?.reference.child(user).child("endedItems").child("\(item.id)").removeValue()
            
            let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(user).child("\(item.id)")
            storageRef.delete() { _ in
                self?.reference.child(user).child("endedItems").child("\(item.id)").removeValue()
                
                self?.reference.child(user).child("chats").child("\(item.id)").observeSingleEvent(of: .value) { snapshot in

                    if let buyers = snapshot.value as? [String: Any] {
                        let keys = buyers.keys

                        for key in keys {
                            self?.reference.child(key).child("chats").child("\(item.id)").removeValue()
                        }

                        self?.reference.child(user).child("chats").child("\(item.id)").removeValue()
                    }
                }
            }
        }
    }
    
    // convert URL to a thumbnail
    func convertThumbnail(url: String, completion: @escaping (UIImage) -> Void) {
        guard let link = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: link) { (data, _, _) in
            if let data = data {
                let image = UIImage(data: data)!
                completion(image)
            }
        }
        task.resume()
    }
    
    // download ended ads from Firebase
    func getEndedAds(completion: @escaping ([String: [String: Any]]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        var items = [String: [String: Any]]()
        var adsReady = 0
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("endedItems").observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: [String: Any]] {
                    items = data
                    for (key, value) in data {
                        let photos = value["photosURL"] as! [String]
                        
                        self?.convertThumbnail(url: photos[0]) { thumbnail in
                            items[key]?["thumbnail"] = thumbnail
                            
                            if let _ = items[key]?["thumbnail"] as? UIImage {
                                adsReady += 1
                            }
                            
                            guard adsReady == items.count else { return }
                            completion(items)
                        }
                    }
                }
            }
        }
    }
    
    // convert dictionary to [Item] model
    func toItemModel(dict: [String: [String: Any]]) -> [Item] {
        var result = [Item]()
        
        for item in dict {
            let thumbnail = item.value["thumbnail"] as? UIImage
            let photosURL = item.value["photosURL"] as? [String]
            let title = item.value["title"] as? String
            let price = item.value["price"] as? Int
            let category = item.value["category"] as? String
            let location = item.value["location"] as? String
            let description = item.value["description"] as? String
            let date = item.value["date"] as? String
            let views = item.value["views"] as? Int
            let saved = item.value["saved"] as? Int
            let lat = item.value["lat"] as? Double
            let long = item.value["long"] as? Double
            let id = item.value["id"] as? Int
            let owner = item.value["owner"] as? String
            
            let model = Item(thumbnail: thumbnail!, photosURL: photosURL!, title: title!, price: price!, category: category!, location: location!, description: description!, date: date!.toDate(), views: views!, saved: saved!, lat: lat!, long: long!, id: id!, owner: owner!)
            
            result.append(model)
        }
        
        return result
    }
    
}
