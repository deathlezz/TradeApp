//
//  ActiveAdsView.swift
//  TradeApp
//
//  Created by deathlezz on 04/03/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class ActiveAdsView: UITableViewController {
    
    var emptyArrayView: UIView!
    
    var header: UILabel!
    
    var activeAds = [Item]()
    
    var reference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Active"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserAds), name: NSNotification.Name("reloadActiveAds"), object: nil)
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        addEmptyArrayView()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / 1.9
    }
    
    // set header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23
    }
    
    // set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeAds.count
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let headerX = view.readableContentGuide.layoutFrame.minX
            
        let label = UILabel()
        label.frame = CGRect.init(x: headerX, y: -13, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = activeAds.count == 1 ? "Found 1 ad" : "Found \(activeAds.count) ads"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .gray
        
        header = label
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "activeAdCell", for: indexPath) as? AdCell {
            if activeAds[indexPath.row].thumbnail != nil {
                cell.thumbnail.image = activeAds[indexPath.row].thumbnail?.resized(to: cell.thumbnail.frame.size)
            } else {
                cell.thumbnail.image = nil
                
                let url = activeAds[indexPath.row].photosURL[0]
                convertThumbnail(url: url) { [weak self] thumbnail in
                    self?.activeAds[indexPath.row].thumbnail = thumbnail

                    DispatchQueue.main.async {
                        cell.thumbnail.image = thumbnail.resized(to: cell.thumbnail.frame.size)
                    }
                }
            }
            
            cell.thumbnail.layer.cornerRadius = 7
            cell.title.text = activeAds[indexPath.row].title
            cell.price.text = "£\(activeAds[indexPath.row].price)"
            cell.availability.text = setExpiryDate(activeAds[indexPath.row].date)
            cell.views.setTitle(activeAds[indexPath.row].views?.description, for: .normal)
            cell.views.isUserInteractionEnabled = false
            cell.saved.setTitle(activeAds[indexPath.row].saved?.description, for: .normal)
            cell.saved.isUserInteractionEnabled = false
            cell.stateButton.layer.borderWidth = 1.5
            cell.stateButton.layer.borderColor = UIColor.systemRed.cgColor
            cell.stateButton.layer.cornerRadius = 7
            cell.stateButton.tag = activeAds[indexPath.row].id
            cell.stateButton.addTarget(self, action: #selector(stateTapped), for: .touchUpInside)
            cell.editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
            cell.editButton.tag = activeAds[indexPath.row].id
            cell.separatorInset = .zero
            return cell
        }
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = activeAds[indexPath.row]
            vc.images = [(activeAds[indexPath.row].thumbnail)!]
            vc.isOpenedByLink = false
            vc.isAdActive = true
            vc.hidesBottomBarWhenPushed = true
            vc.toolbarItems = []
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = activeAds[indexPath.row]
            
            let ac = UIAlertController(title: "Delete ad", message: "Are you sure, you want to delete this ad?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                AppStorage.shared.items.removeAll(where: {$0.id == item.id})
                AppStorage.shared.filteredItems.removeAll(where: {$0.id == item.id})
                
                self?.deleteItem(item: item)
                self?.activeAds.remove(at: indexPath.row)
                
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
            guard let item = activeAds.first(where: {$0.id == sender.tag}) else { return }
            vc.isEditMode = true
            vc.isAdActive = true
            vc.item = item
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // update table view header
    func updateHeader() {
        tableView.beginUpdates()
        header.text = activeAds.count == 1 ? "Found 1 ad" : "Found \(activeAds.count) ads"
        tableView.endUpdates()
    }
    
    // hide toolbar before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserAds()
//        isArrayEmpty()
        navigationController?.isToolbarHidden = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    // remove stored data
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            activeAds.removeAll()
        }
    }
    
    // set item expiry date
    func setExpiryDate(_ startDate: Date) -> String {
        let userCalendar = Calendar.current
        let expiryDate = userCalendar.date(byAdding: .day, value: 30, to: startDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMMM d"
        let formattedExpiryDate = dateFormatter.string(from: expiryDate)
        return "expires \(formattedExpiryDate)"
    }
    
    // set action for tapped state button
    @objc func stateTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Finish ad", message: "Are you sure, you want to finish this ad?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Finish", style: .destructive) { [weak self] _ in
            self?.finishAd(sender)
        })
        present(ac, animated: true)
    }
    
    // finish the ad
    func finishAd(_ sender: UIButton) {
        guard let itemIndex = activeAds.firstIndex(where: {$0.id == sender.tag}) else { return }
        
        let date = Date().toString(shortened: false)
        moveItem(itemId: sender.tag, date: date)
        activeAds.remove(at: itemIndex)
        
        AppStorage.shared.items.removeAll(where: {$0.id == sender.tag})
        AppStorage.shared.filteredItems.removeAll(where: {$0.id == sender.tag})
        
        let indexPath = IndexPath(row: itemIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateHeader()
        isArrayEmpty()
    }
    
    // load user's active ads
    @objc func loadUserAds() {
        DispatchQueue.global().async { [weak self] in
            self?.getActiveAds() { dict in
                let ads = self?.toItemModel(dict: dict) ?? [Item]()
                let sorted = ads.sorted {$0.date > $1.date}
                self?.activeAds.removeAll()
                self?.activeAds = sorted
                
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        guard emptyArrayView == nil else { return }
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
        if activeAds.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // move item from activeItems to endedItems folder
    func moveItem(itemId: Int, date: String) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("activeItems").child("\(itemId)").observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    self?.reference.child(user).child("endedItems").child("\(itemId)").setValue(value)
                    self?.reference.child(user).child("endedItems").child("\(itemId)").child("date").setValue(date)
                    self?.reference.child(user).child("activeItems").child("\(itemId)").removeValue()
                }
            }
        }
    }
    
    // delete item from Firebase
    func deleteItem(item: Item) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
            for i in 0..<item.photosURL.count {
                let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(user).child("\(item.id)").child("image\(i)")
                storageRef.delete() { _ in }
            }
            
            self?.reference.child(user).child("activeItems").child("\(item.id)").removeValue()
            
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
    
    // convert URL to a thumbnail
    func convertThumbnail(url: String, completion: @escaping (UIImage) -> Void) {
        guard let link = URL(string: url) else { return }
        
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: link) { (data, _, _) in
                if let data = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)!
                        completion(image)
                    }
                }
            }
            task.resume()
        }
    }
    
    // download active ads from Firebase
    func getActiveAds(completion: @escaping ([String: [String: Any]]) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("activeItems").observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: [String: Any]] {
                    completion(data)
                }
            }
        }
    }
    
    // convert dictionary to [Item] model
    func toItemModel(dict: [String: [String: Any]]) -> [Item] {
        var result = [Item]()
        
        for item in dict {
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
            
            let model = Item(photosURL: photosURL!, title: title!, price: price!, category: category!, location: location!, description: description!, date: date!.toDate(), views: views!, saved: saved!, lat: lat!, long: long!, id: id!, owner: owner!)
            
            result.append(model)
        }
        
        return result
    }
    
}
