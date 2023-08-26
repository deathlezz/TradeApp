//
//  ViewController.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit
import CoreLocation
import Network
import Firebase

class ViewController: UICollectionViewController, UITabBarControllerDelegate {
    
    let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
    
    var radiusStages = [0, 1, 2, 3, 4, 5, 10, 15, 20, 25, 50, 75, 100, 125, 150, 175, 200]
    
    var emptyArrayView: UIView!
    var refreshControl: UIRefreshControl!
    
    let monitor = NWPathMonitor()
    var isPushed = false
    
    var currentUnit: String!
    var currentFilters = [String: String]()
    
    var delegate: UITabBarController!
    
    var categoriesButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    
    var filterButton: UIBarButtonItem!
    var sortButton: UIBarButtonItem!
    
    var reference: DatabaseReference!
    
    var mail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Recently added"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        checkConnection()
        addEmptyArrayView()
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
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
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        DispatchQueue.global().async { [weak self] in
            self?.resetFilters()
            self?.mail = Utilities.loadUser()
            self?.currentUnit = Utilities.loadDistanceUnit()
            
            self?.getData() { dict in
                AppStorage.shared.items = self?.toItemModel(dict: dict) ?? [Item]()
                self?.loadRecentItems()
                
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    // number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppStorage.shared.filteredItems.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        let thumbnail = UIImage(data: AppStorage.shared.filteredItems[indexPath.item].photos[0]!)
        
        cell.image.image = thumbnail
        cell.title.text = AppStorage.shared.filteredItems[indexPath.item].title
        cell.price.text = "£\(AppStorage.shared.filteredItems[indexPath.item].price)"
        cell.location.text = AppStorage.shared.filteredItems[indexPath.item].location
        cell.date.text = AppStorage.shared.filteredItems[indexPath.item].date.toString(shortened: true)
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for tapped cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = AppStorage.shared.filteredItems[indexPath.item]
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set collection view header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderView {
                headerView.textLabel.text = AppStorage.shared.filteredItems.count == 1 ? "Found 1 ad" : "Found \(AppStorage.shared.filteredItems.count) ads"
                headerView.textLabel.font = UIFont.boldSystemFont(ofSize: 14)
                headerView.textLabel.textColor = .gray
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
        currentUnit = Utilities.loadDistanceUnit()
        changeTitle()
        hideButtons()
        isArrayEmpty()
        collectionView.reloadData()
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        DispatchQueue.global().async { [weak self] in
            self?.getData() { dict in
                
                AppStorage.shared.items = self?.toItemModel(dict: dict) ?? [Item]()

                DispatchQueue.main.async {
                    if self?.currentFilters.isEmpty ?? Bool() {
                        self?.loadRecentItems()
                    } else {
                        self?.applyFilters()
                    }

                    refreshControl.endRefreshing()
                    self?.isArrayEmpty()
                    self?.collectionView.reloadData()
                }
            }
        }
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
    
    // sort items in the array
    @objc func sort() {
        let ac = UIAlertController(title: "Sort items by", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Lowest price", style: .default) { [weak self] _ in
            AppStorage.shared.filteredItems.sort(by: {$0.price < $1.price})
            self?.currentFilters["Sort"] = "Lowest price"
            Utilities.saveFilters(self!.currentFilters)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Highest price", style: .default) { [weak self] _ in
            AppStorage.shared.filteredItems.sort(by: {$0.price > $1.price})
            self?.currentFilters["Sort"] = "Highest price"
            Utilities.saveFilters(self!.currentFilters)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Date added", style: .default) { [weak self] _ in
            AppStorage.shared.filteredItems.sort(by: {$0.date < $1.date})
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
    
    // set view and tab bar item title
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
    
    // apply all filters
    func applyFilters() {
        checkMainFilters()
        checkPriceFilter()
        checkSortFilter()
        checkLocationFilter()
        
        if currentFilters["Location"] == nil {
            collectionView.reloadData()
        }
    }
    
    // stop double tap for all tab items
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
    
    // check search and category filter
    func checkMainFilters() {
        if currentFilters["Search"] != nil && currentFilters["Category"] != nil {
            if currentFilters["Category"] == categories[0] {
                AppStorage.shared.filteredItems = AppStorage.shared.items
                AppStorage.shared.filteredItems = AppStorage.shared.filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            } else {
                AppStorage.shared.filteredItems = AppStorage.shared.items.filter {$0.category == currentFilters["Category"]}
                AppStorage.shared.filteredItems = AppStorage.shared.filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            }
        } else if currentFilters["Search"] != nil {
            AppStorage.shared.filteredItems = AppStorage.shared.items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
        } else if currentFilters["Category"] != nil {
            if currentFilters["Category"] == categories[0] {
                AppStorage.shared.filteredItems = AppStorage.shared.items
            } else {
                AppStorage.shared.filteredItems = AppStorage.shared.items.filter {$0.category == currentFilters["Category"]}
            }
        }
    }
    
    // check price filter
    func checkPriceFilter() {
        if currentFilters["PriceFrom"] != nil && currentFilters["PriceTo"] != nil {
            AppStorage.shared.filteredItems = AppStorage.shared.filteredItems.filter {$0.price >= Int(currentFilters["PriceFrom"]!)! && $0.price <= Int(currentFilters["PriceTo"]!)!}
        } else if currentFilters["PriceFrom"] != nil {
            AppStorage.shared.filteredItems = AppStorage.shared.filteredItems.filter {$0.price >= Int(currentFilters["PriceFrom"]!)!}
        } else if currentFilters["PriceTo"] != nil {
            AppStorage.shared.filteredItems = AppStorage.shared.filteredItems.filter {$0.price <= Int(currentFilters["PriceTo"]!)!}
        }
    }
    
    // check sort filter
    func checkSortFilter() {
        if currentFilters["Sort"] != nil {
            if currentFilters["Sort"] == "Lowest price" {
                AppStorage.shared.filteredItems.sort(by: {$0.price < $1.price})
            } else if currentFilters["Sort"] == "Highest price" {
                AppStorage.shared.filteredItems.sort(by: {$0.price > $1.price})
            } else if currentFilters["Sort"] == "Date added" {
                AppStorage.shared.filteredItems.sort(by: {$0.date < $1.date})
            }
        }
    }
    
    // check location filter
    func checkLocationFilter() {
        guard let radiusCounter = Int(currentFilters["Radius"] ?? "0") else { return }
        let radius = radiusStages[radiusCounter]
        
        var matched = [Item]()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        if currentFilters["Location"] != nil {
            
            Utilities.forwardGeocoding(address: currentFilters["Location"]!) { [weak self] (lat, long) in
                let cityLocation = CLLocation(latitude: lat, longitude: long)
                
                var unit: Double
                
                if self?.currentUnit == "mi" {
                    unit = 1609
                } else {
                    unit = 1000
                }
                
                for item in AppStorage.shared.filteredItems {
                    
                    let itemLocation = CLLocation(latitude: item.lat!, longitude: item.long!)
                    let distance = Int(cityLocation.distance(from: itemLocation) / unit)
                    
                    if Int(distance) <= radius {
                        matched.append(item)
                    }
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                AppStorage.shared.filteredItems = matched
                self.collectionView.reloadData()
            }
        }
    }
    
    // monitor connection changes
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
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
            } else {
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
    
    // load recently added items
    func loadRecentItems() {
        AppStorage.shared.recentlyAdded.removeAll()
        
        for item in AppStorage.shared.items {
            if isItemRecent(item.date) {
                AppStorage.shared.recentlyAdded.append(item)
            }
        }
        
        AppStorage.shared.filteredItems = AppStorage.shared.recentlyAdded
    }
    
    // check if item was added in the last 24h
    func isItemRecent(_ itemDate: Date) -> Bool {
        let now = Date.now
        let soon = itemDate.addingTimeInterval(86400)
        
        return soon >= now
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - 25, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .clear
        myView.isHidden = true
        myView.isUserInteractionEnabled = false
        myView.addSubview(label)
        view.addSubview(myView)
        emptyArrayView = myView
    }
    
    // check if array is empty or not
    func isArrayEmpty() {
        if AppStorage.shared.filteredItems.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // convert URLs into dictionary Data
    func convertImages(urls: [String], completion: @escaping ([String: Data]) -> Void) {
        var images = [String: Data]()
        
        let links = urls.sorted(by: <).map {URL(string: $0)}
        
        for (index, url) in links.enumerated() {
            let task = URLSession.shared.dataTask(with: url!) { (data, _, _) in
                if let data = data {
                    images["image\(index)"] = data
                }

                guard images.keys.count == links.count else { return }
                completion(images)
            }

            task.resume()
        }
    }
    
    // download all active items from firebase & convert images urls to data array
    func getData(completion: @escaping ([String: [String: Any]]) -> Void) {
        var items = [String: [String: Any]]()
        var adsReady = 0
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: [String: Any]] {
                    
                    for user in data {
                        guard let activeItems = data[user.key]?["activeItems"] as? [String: [String: Any]] else { return }
                        
                        for item in activeItems {
                            items["\(item.key)"] = item.value
                            
                            let photos = item.value["photos"] as! [String: String]
                            
                            let fixedUrls = photos.values.sorted(by: <).map {String($0)}
                            
                            self?.convertImages(urls: fixedUrls) { images in
                                items[item.key]?["photos"] = images
                                
                                if let _ = items[item.key]?["photos"] as? [String: Data] {
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
    }
    
    // convert dictionary to [Item] model
    func toItemModel(dict: [String: [String: Any]]) -> [Item] {
        var result = [Item]()
        
        for item in dict {
            let dictPhotos = item.value["photos"] as! [String: Data]
            let sorted = dictPhotos.sorted(by: { $0.0 < $1.0 })
            let arrayPhotos = sorted.map {$0.value}
            
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
            
            let model = Item(photos: arrayPhotos, title: title!, price: price!, category: category!, location: location!, description: description!, date: date!.toDate(), views: views!, saved: saved!, lat: lat!, long: long!, id: id!, owner: owner!)
            
            result.append(model)
        }
        
        return result
    }
    
    // update empty array view y position
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = view.safeAreaInsets.top
        let refreshHeight = refreshControl.bounds.height
        var offset = CGFloat()
        
        if refreshControl.isRefreshing {
            offset = -scrollView.contentOffset.y - safeAreaTop + refreshHeight
        } else {
            offset = -scrollView.contentOffset.y - safeAreaTop
        }

        let screenSize = UIScreen.main.bounds.size
        emptyArrayView.frame = CGRect(x: 0, y: offset, width: screenSize.width, height: screenSize.height)
    }
    

}
