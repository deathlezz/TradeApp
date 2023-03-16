//
//  ViewController.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class ViewController: UICollectionViewController, UITabBarControllerDelegate {
    
    let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
    
    var currentFilters = [String: String]()
    
    var delegate: UITabBarController!
    
    var categoriesButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    
    var filterButton: UIBarButtonItem!
    var sortButton: UIBarButtonItem!
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Recently added"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tabBarController?.delegate = self
        
        categoriesButton = UIBarButtonItem(image: .init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(categoriesTapped))
        
        searchButton = UIBarButtonItem(image: .init(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        
        filterButton = UIBarButtonItem(image: .init(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(filterTapped))
        
        sortButton = UIBarButtonItem(image: .init(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sort))
        
        navigationItem.leftBarButtonItems = [categoriesButton, sortButton]
        navigationItem.rightBarButtonItems = [searchButton, filterButton]
        
        sortButton.isHidden = true
        filterButton.isHidden = true
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        DispatchQueue.global().async { [weak self] in
            self?.resetFilters()
            let newUser = User(mail: "mail@wp.pl", password: "passWord123")
            Storage.shared.users.append(newUser)
            self?.mail = Utilities.loadUser()
            self?.loadData()
            self?.loadItems()
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    // number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Storage.shared.filteredItems.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        let thumbnail = UIImage(data: Storage.shared.filteredItems[indexPath.item].photos[0]!)
        
        cell.image.image = thumbnail
        cell.title.text = Storage.shared.filteredItems[indexPath.item].title
        cell.price.text = "£\(Storage.shared.filteredItems[indexPath.item].price)"
        cell.location.text = Storage.shared.filteredItems[indexPath.item].location
        cell.date.text = Storage.shared.filteredItems[indexPath.item].date.formatDate()
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for tapped cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
//            vc.imgs = filteredItems[indexPath.item].photos.map {UIImage(data: $0!)}
            vc.item = Storage.shared.filteredItems[indexPath.item]
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set collection view header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderView {
                headerView.textLabel.text = "Found \(Storage.shared.filteredItems.count) ads"
                headerView.textLabel.font = UIFont.boldSystemFont(ofSize: 12)
                headerView.textLabel.textColor = .darkGray
                return headerView
            }
            
        default:
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    // set hide/show bars on scroll
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            setTabBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            setTabBarHidden(false, animated: true)
        }
    }
    
    // set action for categories button
    @objc func categoriesTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryView") as? CategoryView {
            vc.hidesBottomBarWhenPushed = true
            vc.categories = categories
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set action for search button
    @objc func searchTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "searchView") as? SearchView {
            vc.hidesBottomBarWhenPushed = true
            vc.categories = categories
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // refresh collection view before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = false
        currentFilters = Utilities.loadFilters()
        changeTitle()
        hideButtons()
        collectionView.reloadData()
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        loadItems()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // show or hide filter and sort buttons
    func hideButtons() {
        if currentFilters["Category"] != nil || currentFilters["Search"] != nil {
            filterButton.isHidden = false
            sortButton.isHidden = false
        } else {
            filterButton.isHidden = true
            sortButton.isHidden = true
        }
    }
    
    // load data in the background
    func loadData() {
        let car = UIImage(systemName: "car")?.pngData()
        let plus = UIImage(systemName: "plus")?.pngData()
        
        print("before index")
        guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        print("after index")
        
        for _ in 0...3 {
            let tesla = Item(photos: [car, plus], title: "Tesla Model X", price: 6000, category: "Vehicles", location: "London", description: "Tesla for sale", date: Date(), views: 0, saved: 0, lat: 51.50334660, long: -0.07939650, id: itemID())
            let bmw = Item(photos: [car, plus], title: "BMW E36 2.0 LPG", price: 500, category: "Vehicles", location: "Stirling", description: "E36 for sale", date: Date(), views: 0, saved: 0, lat: 56.116524, long: -3.936903, id: itemID())
            let fiat = Item(photos: [car, plus], title: "Fiat Punto 1.9 TDI", price: 1200, category: "Vehicles", location: "Glasgow", description: "Punto for sale", date: Date(), views: 0, saved: 0, lat: 55.864239, long: -4.251806, id: itemID())
            
            Storage.shared.users[index].activeItems.append(tesla)
            Storage.shared.users[index].activeItems.append(bmw)
            Storage.shared.users[index].activeItems.append(fiat)
            
            Storage.shared.recentlyAdded.append(fiat)
        }
        
        Storage.shared.filteredItems = Storage.shared.recentlyAdded
    }
    
    // sort items in the array
    @objc func sort() {
        let ac = UIAlertController(title: "Sort items by", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Lowest price", style: .default) { [weak self] _ in
            Storage.shared.filteredItems.sort(by: {$0.price < $1.price})
            self?.currentFilters["Sort"] = "Lowest price"
            Utilities.saveFilters(self!.currentFilters)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Highest price", style: .default) { [weak self] _ in
            Storage.shared.filteredItems.sort(by: {$0.price > $1.price})
            self?.currentFilters["Sort"] = "Highest price"
            Utilities.saveFilters(self!.currentFilters)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Date added", style: .default) { [weak self] _ in
            Storage.shared.filteredItems.sort(by: {$0.date < $1.date})
            self?.currentFilters["Sort"] = "Date added"
            Utilities.saveFilters(self!.currentFilters)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // set action for filter button
    @objc func filterTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "filterView") as? FilterView {
            vc.hidesBottomBarWhenPushed = true
            vc.categories = categories
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set view title
    func changeTitle() {
        if currentFilters["Category"] != nil {
            title = currentFilters["Category"]
            navigationController?.tabBarItem.title = "Search"
        } else {
            title = "Recently added"
            navigationController?.tabBarItem.title = "Search"
        }
    }
    
    // reset filters on start
    func resetFilters() {
        currentFilters.removeAll()
        Utilities.saveFilters(currentFilters)
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
    
    // load all active items
    func loadItems() {
        Storage.shared.items.removeAll()
        let users = Storage.shared.users
        
        for user in users {
            for item in user.activeItems {
                Storage.shared.items.append(item!)
            }
        }
        print(Storage.shared.items.count)
    }
    
    // stop double tap for all tab items
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
    
    // create unique item ID
    func itemID() -> Int {
        var uniqueID: Int!
        let usedIDs = Storage.shared.items.map {$0.id}
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
    
}

