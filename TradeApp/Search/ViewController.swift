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

class ViewController: UICollectionViewController, UITabBarControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music"]
    
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
            self?.currentUnit = Utilities.loadDistanceUnit()
            
            self?.getData() { dict in
                let newItems = self?.toItemModel(dict: dict) ?? [Item]()
                AppStorage.shared.items = newItems
                self?.loadRecentItems()
                
                DispatchQueue.main.async {
                    self?.isArrayEmpty()
                    self?.collectionView.reloadData()
                    
                    guard let itemID = SceneDelegate.id else { return }
                    self?.showItem(id: itemID)
                    SceneDelegate.id = nil
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell {
            if AppStorage.shared.filteredItems[indexPath.item].thumbnail != nil {
                cell.image.image = AppStorage.shared.filteredItems[indexPath.item].thumbnail?.resized(to: cell.image.frame.size)
            } else {
                cell.image.image = nil
                
                let url = AppStorage.shared.filteredItems[indexPath.item].photosURL[0]
                convertThumbnail(url: url) { thumbnail in
                    AppStorage.shared.filteredItems[indexPath.item].thumbnail = thumbnail

                    DispatchQueue.main.async {
                        cell.image.image = thumbnail.resized(to: cell.image.frame.size)
                    }
                }
            }
            
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
        return UICollectionViewCell()
    }
    
    // set action for tapped cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            let item = AppStorage.shared.filteredItems[indexPath.item]
            vc.item = item
            vc.images = [item.thumbnail!]
            vc.isOpenedByLink = false
            vc.isAdActive = true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set collection view header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderView {
                let screenWidth = UIScreen.main.bounds.width
                let headerX = view.readableContentGuide.layoutFrame.minX
                headerView.frame = CGRect(x: headerX, y: 0, width: screenWidth / 1.5, height: 15)
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
    
    // stop refreshing after leaving view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    // show item when all items are downloaded
    func showItem(id: Int) {
        guard let item = AppStorage.shared.items.first(where: {$0.id == id}) else {
            let ac = UIAlertController(title: "Not found", message: "Item is not available", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = item
            vc.isOpenedByLink = true
            vc.isAdActive = true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        DispatchQueue.global().async { [weak self] in
            self?.getData() { dict in
                AppStorage.shared.items.removeAll()
                let newItems = self?.toItemModel(dict: dict) ?? [Item]()
                AppStorage.shared.items = newItems

                DispatchQueue.main.async {
                    if self?.currentFilters.isEmpty ?? Bool() {
                        self?.loadRecentItems()
                    } else {
                        self?.applyFilters()
                    }
                    
                    refreshControl.endRefreshing()
                    self?.isArrayEmpty()
                    
                    if self?.currentFilters["Location"] == nil {
                        self?.collectionView.reloadData()
                    }
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
        
        if currentFilters["Location"] != nil {
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
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
                guard !self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                        vc.navigationItem.hidesBackButton = true
                        self?.isPushed = true
                        self?.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            } else {
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
        AppStorage.shared.recentlyAdded.removeAll(keepingCapacity: false)
        
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
        if AppStorage.shared.filteredItems.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
    // convert URL to a thumbnail
    func convertThumbnail(url: String, completion: @escaping (UIImage) -> Void) {
        guard let link = URL(string: url) else { return }
        
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: link) { (data, _, _) in
                if let data = data {
                    DispatchQueue.main.async {
                        let thumbnail = UIImage(data: data)!
                        completion(thumbnail)
                    }
                }
            }
            task.resume()
        }
    }
    
    // download all active items & convert thumbnails to UIImage
    func getData(completion: @escaping ([String: [String: Any]]) -> Void) {
        var items = [String: [String: Any]]()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.observeSingleEvent(of: .value) { snapshot in
                defer {
                    dispatchGroup.leave()
                }
                
                if let data = snapshot.value as? [String: [String: Any]] {
                    for user in data {
                        if let activeItems = data[user.key]?["activeItems"] as? [String: [String: Any]] {
                            for item in activeItems {
                                items["\(item.key)"] = item.value
                            }
                        }
                    }
                } else {
                    guard let refresh = self?.refreshControl else { return }
                    
                    if refresh.isRefreshing {
                        refresh.endRefreshing()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(items)
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
    
    // set scalable size for item cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let minX = view.readableContentGuide.layoutFrame.minX
        
        let cellWidth = screenWidth / 2 - minX * 1.4
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // set collection view edge insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let minX = view.readableContentGuide.layoutFrame.minX
        return UIEdgeInsets(top: 10, left: minX, bottom: 10, right: minX)
    }

}
