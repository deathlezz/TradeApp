//
//  SavedView.swift
//  TradeApp
//
//  Created by deathlezz on 26/11/2022.
//

import UIKit
import Network

class SavedView: UICollectionViewController {
    
    var savedItems = [SavedAd]()
    
    var isPushed: Bool!
    
    var selectButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    let monitor = NWPathMonitor()
    var connectedOnLoad: Bool!
    var connected: Bool!
    
    var selectedCells = [UICollectionViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        checkConnection()
        
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        
        navigationItem.rightBarButtonItems = [selectButton]
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        DispatchQueue.global().async { [weak self] in
            self?.savedItems = Utilities.loadItems()
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
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
        
        let img = UIImage(data: savedItems[indexPath.item].image!)
        
        cell.image.image = img
        cell.title.text = savedItems[indexPath.item].title
        cell.price.text = "£\(savedItems[indexPath.item].price)"
        cell.location.text = savedItems[indexPath.item].location
        cell.date.text = savedItems[indexPath.item].date?.formatDate()
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for selected cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if navigationItem.rightBarButtonItems == [selectButton] && connected {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
//                vc.imgs = savedItems[indexPath.item].photos.map {UIImage(data: $0!)}
//                vc.item = savedItems[indexPath.item]
                vc.hidesBottomBarWhenPushed = true
                isPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if navigationItem.rightBarButtonItems != [selectButton] && !connected {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            if cell.isSelected {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.systemRed.cgColor
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { finished in
                    self.selectedCells.append(cell)
                    self.showButton()
                    self.updateHeader()
                }
            }
        } else {
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
                headerView.textLabel.text = savedItems.count == 1 ? "Found 1 ad" : "Found \(savedItems.count) ads"
//                headerView.textLabel.text = "Found \(savedItems.count) ads"
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
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // refresh collection view before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.isToolbarHidden = true
        savedItems = Utilities.loadItems()
        isPushed = false
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
                Utilities.saveItems(self.savedItems)
                self.updateHeader()
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
    
    // check for internet connection
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            
            if self.connectedOnLoad != nil {
                self.connected = !self.connected
                self.pushToNoConnectionView()
                print("Connected: \(self.connected!)")
            }
            
            guard self.connectedOnLoad == nil else { return }
            
            if path.status == .satisfied {
                self.connectedOnLoad = true
                self.connected = true
            } else {
                self.connectedOnLoad = false
                self.connected = false
            }
            
            self.pushToNoConnectionView()
            print("Connected: \(self.connected!)")
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // show no connection view
    func pushToNoConnectionView() {
        DispatchQueue.main.async {
            if self.connected == false && self.isPushed {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                    vc.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    // show no connection alert
    func connectionAlert() {
        let ac = UIAlertController(title: "No Connection", message: "Restore internet and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}
