//
//  SavedView.swift
//  TradeApp
//
//  Created by deathlezz on 26/11/2022.
//

import UIKit
import Network
import Firebase

class SavedView: UICollectionViewController {
    
    var savedItems = [Item]()
    var loggedUser: String!
    
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
        addAmptyArrayView()
        
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        
        navigationItem.rightBarButtonItems = [selectButton]
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        loggedUser = Utilities.loadUser()
        
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        
        let thumbnail = UIImage(data: savedItems[indexPath.item].photos[0]!)
        
        cell.image.image = thumbnail
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
    
    // set action for selected cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if navigationItem.rightBarButtonItems == [selectButton] && monitor.currentPath.status == .satisfied {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
                let item = savedItems[indexPath.item]
                vc.item = AppStorage.shared.items.first(where: {$0.id == item.id})
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
                self.selectedItems.remove(at: indexPath.item)
                self.showButton()
                self.updateHeader()
            }
        }
    }
    
    // set number of showed ads as collection view header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderView {
                headerView.textLabel.text = savedItems.count == 1 ? "Found 1 ad" : "Found \(savedItems.count) ads"
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
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        updateSavedItems()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // refresh collection view before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.isToolbarHidden = true
        isDetailShown = false
        savedItems = Utilities.loadItems()
        updateSavedItems()
        isArrayEmpty()
        collectionView.reloadData()
    }
    
    // cancel selection after view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTapped()
    }

    // set action for select button
    @objc func selectTapped() {
        guard !savedItems.isEmpty else { return }
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
                self.selectedCells.removeAll()
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
        
        if navigationItem.rightBarButtonItems != [selectButton] {
            guard let selected = collectionView.indexPathsForSelectedItems else { return }
            label?.text = selected.count == 1 ? "Selected 1 ad" : "Selected \(selected.count) ads"
            
        } else {
            label?.text = savedItems.count == 1 ? "Found 1 ad" : "Found \(savedItems.count) ads"
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
                print("Connection is not satisfied")
                guard !self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                        vc.navigationItem.hidesBackButton = true
                        self?.isPushed = true
                        self?.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            } else if path.status == .satisfied && self.isDetailShown {
                print("Connection is satisfied")
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
    func updateSavedItems() {
        for item in savedItems {
            if let first = AppStorage.shared.items.first(where: {$0.id == item.id}) {
                // check if these items are equal
                if first.photos[0] != item.photos[0] || first.title != item.title || first.price != item.price ||
                    first.date != item.date || first.location != item.location {
                    guard let index = savedItems.firstIndex(where: {$0.id == item.id}) else { return }
                    Utilities.removeItems([item])
                    savedItems.remove(at: index)
                    Utilities.saveItem(first)
                    savedItems.insert(first, at: index)
                }
            } else {
                // remove that item from Core Data
                Utilities.removeItems([item])
                savedItems.removeAll(where: {$0.id == item.id})
            }
        }
    }
    
    // set up empty array view
    func addAmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - 25, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
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
    
}
