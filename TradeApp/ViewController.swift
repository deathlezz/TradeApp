//
//  ViewController.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class ViewController: UICollectionViewController {
    
    let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
    
    var currentFilters = [String: String]()
    
    var categoriesButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    
    var filterButton: UIBarButtonItem!
    var sortButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(resetFilters), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        title = "Recently added"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
            self?.loadData()
            
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
        return filteredItems.count
    }
    
    // set table view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        
        cell.title.text = filteredItems[indexPath.row].title
        cell.price.text = "£\(filteredItems[indexPath.row].price)"
        cell.location.text = filteredItems[indexPath.row].location
        cell.date.text = filteredItems[indexPath.row].date.formatDate()
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for tapped cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = filteredItems[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
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
        navigationController?.hidesBarsOnSwipe = true
        currentFilters = Utilities.loadFilters()
        changeTitle()
        hideButtons()
        collectionView.reloadData()
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // show or hide filter and sort buttons
    func hideButtons() {
        if isCategoryApplied || isSearchApplied {
            filterButton.isHidden = false
            sortButton.isHidden = false
        } else {
            filterButton.isHidden = true
            sortButton.isHidden = true
        }
    }
    
    // load data in the background
    func loadData() {
        for _ in 0...3 {
            let tesla = Item(category: "Vehicles", title: "Tesla Model X", price: 6000, location: "London", date: Date())
            let bmw = Item(category: "Vehicles", title: "BMW E36 2.0 LPG", price: 500, location: "Stirling", date: Date())
            let fiat = Item(category: "Vehicles", title: "Fiat Punto 1.9 TDI", price: 1200, location: "Glasgow", date: Date())
            items.append(tesla)
            items.append(bmw)
            items.append(fiat)
            recentlyAdded.append(fiat)
        }
        
        filteredItems = recentlyAdded
    }
    
    // sort items in the array
    @objc func sort() {
        let ac = UIAlertController(title: "Sort items by", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Lowest price", style: .default) { [weak self] _ in
            filteredItems.sort(by: {$0.price < $1.price})
            self?.currentFilters["Sort"] = "Lowest price"
            Utilities.saveFilters(self!.currentFilters)
            isFilterApplied = true
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Highest price", style: .default) { [weak self] _ in
            filteredItems.sort(by: {$0.price > $1.price})
            self?.currentFilters["Sort"] = "Highest price"
            Utilities.saveFilters(self!.currentFilters)
            isFilterApplied = true
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Date added", style: .default) { [weak self] _ in
            filteredItems.sort(by: {$0.date < $1.date})
            self?.currentFilters["Sort"] = "Date added"
            Utilities.saveFilters(self!.currentFilters)
            isFilterApplied = true
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
        if isCategoryApplied {
            title = currentFilters["Category"]
            navigationController?.tabBarItem.title = "Search"
        } else {
            title = "Recently added"
            navigationController?.tabBarItem.title = "Search"
        }
    }
    
    @objc func resetFilters() {
        currentFilters.removeAll()
        Utilities.saveFilters(currentFilters)
    }
    
}

