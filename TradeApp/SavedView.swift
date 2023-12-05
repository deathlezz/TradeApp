//
//  SavedView.swift
//  TradeApp
//
//  Created by deathlezz on 26/11/2022.
//

import UIKit
import Network
import Firebase

class SavedView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var savedItems = [Item]()
    
    let monitor = NWPathMonitor()
    var isPushed = false
    var isDetailShown = false
    
    var emptyArrayView: UIView!
    var reference: DatabaseReference!
    
    var selectButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    var selectedCells = [UICollectionViewCell]()
    var selectedItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        checkConnection()
        addEmptyArrayView()
        
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        
        navigationItem.rightBarButtonItems = [selectButton]
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
    }
    
    // number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // set number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell {
            cell.image.image = savedItems[indexPath.row].thumbnail?.resized(to: cell.image.frame.size)
            
            let url = savedItems[indexPath.row].photosURL[0]
            convertThumbnail(url: url) { [weak self] thumbnail in
                self?.savedItems[indexPath.row].thumbnail = thumbnail

                DispatchQueue.main.async {
                    cell.image.image = nil
                    cell.image.image = thumbnail.resized(to: cell.image.frame.size)
                }
            }
            
            cell.title.text = savedItems[indexPath.item].title
            cell.price.text = "£\(savedItems[indexPath.item].price)"
            cell.location.text = savedItems[indexPath.item].location
            cell.date.text = savedItems[indexPath.item].date.toString(shortened: true)
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.backgroundColor = .white
            return cell
        }
        return UICollectionViewCell()
    }
    
    // set action for selected cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if navigationItem.rightBarButtonItems == [selectButton] && monitor.currentPath.status == .satisfied {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
                let item = savedItems[indexPath.item]
                vc.item = AppStorage.shared.items.first(where: {$0.id == item.id})
                vc.images = [item.thumbnail!]
                vc.hidesBottomBarWhenPushed = true
                isDetailShown = true
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if navigationItem.rightBarButtonItems != [selectButton] {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            if cell.isSelected {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.systemRed.cgColor
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { finished in
                    self.selectedCells.append(cell)
                    self.selectedItems.append(self.savedItems[indexPath.item])
                    self.showButton()
                    self.updateHeader()
                }
            }
        } else if navigationItem.rightBarButtonItems == [selectButton] && monitor.currentPath.status != .satisfied {
            connectionAlert()
        }
    }
    
    // set action for deselected cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if !cell.isSelected {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.transform = .identity
            }) { finished in
                guard let index = self.selectedCells.firstIndex(of: cell) else { return }
                self.selectedCells.remove(at: index)
                self.showButton()
                self.updateHeader()
            }
        }
    }
    
    // set number of showed ads as collection view header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderView {
                let itemsNumber = collectionView.numberOfItems(inSection: 0)
                let screenWidth = UIScreen.main.bounds.width
                let headerX = view.readableContentGuide.layoutFrame.minX
                headerView.frame = CGRect(x: headerX, y: 0, width: screenWidth / 1.5, height: 15)
                headerView.textLabel.text = itemsNumber == 1 ? "Found 1 ad" : "Found \(itemsNumber) ads"
                headerView.textLabel.font = UIFont.boldSystemFont(ofSize: 14)
                headerView.textLabel.textColor = .gray
                return headerView
            }
            
        } else {
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    // set hide/show bars on scroll
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            setTabBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            setTabBarHidden(false, animated: true)
        }
    }
    
    // refresh collection view before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.isToolbarHidden = true
        isDetailShown = false
        savedItems = Utilities.loadItems()
        
        DispatchQueue.global().async { [weak self] in
            self?.updateSavedItems() {
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    // cancel selection after view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            savedItems.removeAll(keepingCapacity: false)
        }
        
        cancelTapped()
    }

    // set action for select button
    @objc func selectTapped() {
        guard !savedItems.isEmpty else { return }
        guard monitor.currentPath.status == .satisfied else { return }
        collectionView.allowsMultipleSelection = true
        navigationItem.rightBarButtonItems = [cancelButton, deleteButton]
        deleteButton.isEnabled = false
        updateHeader()
    }
    
    // set action for cancel button
    @objc func cancelTapped() {
        collectionView.allowsMultipleSelection = false
        navigationItem.rightBarButtonItems = [selectButton]
        updateHeader()
        
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        
        for indexPath in selected {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        for cell in selectedCells {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.transform = .identity
            }) { finished in
                self.selectedCells.removeAll(keepingCapacity: false)
                self.selectedItems.removeAll(keepingCapacity: false)
            }
        }
    }
    
    // set action for delete button
    @objc func deleteTapped() {
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        guard selected.count > 0 else { return }
        
        let indexes = selected.map { $0.item }
        
        collectionView.allowsMultipleSelection = false
        navigationItem.rightBarButtonItems = [selectButton]
        
        for indexPath in selected {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        savedItems = self.savedItems.enumerated().filter {!indexes.contains($0.offset)}.map {$0.element}
        collectionView.deleteItems(at: selected)
        
        for cell in selectedCells {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.transform = .identity
            }) { finished in
                self.selectedCells.removeAll()
                self.removeFromSaved()
                Utilities.removeItems(self.selectedItems)
                self.selectedItems.removeAll()
                self.updateHeader()
                self.isArrayEmpty()
            }
        }
    }
    
    // set show/hide delete button
    func showButton() {
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        
        if selected.count > 0 {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
    // update collection view header
    func updateHeader() {
        let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        let label = header[0].subviews[0] as? UILabel
        
        let itemsNumber = collectionView.numberOfItems(inSection: 0)
        
        if navigationItem.rightBarButtonItems != [selectButton] {
            guard let selected = collectionView.indexPathsForSelectedItems else { return }
            label?.text = selected.count == 1 ? "Selected 1 ad" : "Selected \(selected.count) ads"
            
        } else {
            label?.text = itemsNumber == 1 ? "Found 1 ad" : "Found \(itemsNumber) ads"
        }
    }
    
    // set hide/show tab bar
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        if tabBar.isHidden == hidden { return }
        let frame = tabBar.frame
        let offset = hidden ? frame.size.height : -frame.size.height
        let duration = animated ? 0.2 : 0.0
        tabBar.isHidden = false

        UIView.animate(withDuration: duration, animations: {
            tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
        }, completion: { (true) in
            tabBar.isHidden = hidden
        })
    }
    
    // monitor connection changes
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            
            if path.status != .satisfied && self.isDetailShown {
                // show connection alert on main thread
                guard !self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                        vc.navigationItem.hidesBackButton = true
                        self?.isPushed = true
                        self?.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            } else if path.status == .satisfied && self.isDetailShown {
                guard self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
                    self?.isPushed = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // show no connection alert
    func connectionAlert() {
        let ac = UIAlertController(title: "No Connection", message: "Restore internet and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // update items on load
    func updateSavedItems(completion: @escaping () -> Void) {
        guard savedItems.count > 0 else { return completion() }
        
        DispatchQueue.global().async { [weak self] in
            self?.getData() { dict in
                let oldSaved = self?.savedItems ?? [Item]()
                let newSaved = self?.toItemModel(dict: dict) ?? [Item]()
                self?.savedItems = newSaved

                DispatchQueue.main.async {
                    Utilities.removeItems(oldSaved)
                    
                    for item in newSaved {
                        Utilities.saveItem(item)
                    }
                    
                    completion()
                }
            }
        }
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        guard emptyArrayView == nil else { return }
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - 25, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.center = myView.center
        myView.isHidden = true
        myView.isUserInteractionEnabled = false
        myView.addSubview(label)
        view.addSubview(myView)
        emptyArrayView = myView
    }
    
    // check if array is empty or not
    func isArrayEmpty() {
        if savedItems.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // update number of saved in Firebase
    func removeFromSaved() {
        for item in selectedItems {
            DispatchQueue.global().async { [weak self] in
                self?.reference.child(item.owner).child("activeItems").child("\(item.id)").child("saved").observeSingleEvent(of: .value) { snapshot in
                    if let saved = snapshot.value as? Int {
                        self?.reference.child(item.owner).child("activeItems").child("\(item.id)").child("saved").setValue(saved - 1)
                    }
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
    
    // download active items from firebase & convert images urls to data array
    func getData(completion: @escaping ([String: [String: Any]]) -> Void) {
        var items = [String: [String: Any]]()
        var adsReady = 0
        
        DispatchQueue.global().async { [weak self] in
            guard let saved = self?.savedItems else { return }
            
            for item in saved {
                self?.reference.child(item.owner).child("activeItems").child("\(item.id)").observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? [String: Any] {
                        // add item to existed items
                        items["\(item.id)"] = value
                        adsReady += 1
                        
                        guard adsReady == items.count else { return }
                        completion(items)
                        
//                        let photos = value["photosURL"] as! [String]
//                        
//                        self?.convertThumbnail(url: photos[0]) { thumbnail in
//                            items["\(item.id)"]?["thumbnail"] = thumbnail
//                            
//                            if let _ = items["\(item.id)"]?["thumbnail"] as? UIImage {
//                                adsReady += 1
//                            }
//                            
//                            guard adsReady == items.count else { return }
//                            completion(items)
//                        }
                        
                    } else {
                        completion(items)
                    }
                }
            }
        }
    }
    
    // convert dictionary to [Item] model
    func toItemModel(dict: [String: [String: Any]]) -> [Item] {
        var result = [Item]()
        
        for item in dict {
//            let thumbnail = item.value["thumbnail"] as? UIImage
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
    
    // update empty array view y position
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = view.safeAreaInsets.top
        let offset = -scrollView.contentOffset.y - safeAreaTop
        let screenSize = UIScreen.main.bounds.size
        emptyArrayView.frame = CGRect(x: 0, y: offset, width: screenSize.width, height: screenSize.height)
    }
    
    // set scalable size for item cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let minX = view.readableContentGuide.layoutFrame.minX
        
        let cellWidth = screenWidth / 2 - minX * 1.5
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // set collection view edge insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let minX = view.readableContentGuide.layoutFrame.minX
        return UIEdgeInsets(top: 10, left: minX, bottom: 10, right: minX)
    }
    
}
