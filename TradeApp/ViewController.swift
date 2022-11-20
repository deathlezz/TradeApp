//
//  ViewController.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var categoriesButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    
    var filterButton: UIBarButtonItem!
    var sortButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        categoriesButton = UIBarButtonItem(image: .init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(categoriesTapped))
        
        searchButton = UIBarButtonItem(image: .init(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        
        filterButton = UIBarButtonItem(image: .init(systemName: "slider.horizontal.3"), style: .plain, target: self, action: nil)
        
        sortButton = UIBarButtonItem(image: .init(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sort))
        
        navigationItem.leftBarButtonItems = [categoriesButton, sortButton]
        navigationItem.rightBarButtonItems = [searchButton, filterButton]
        
        sortButton.isHidden = true
        filterButton.isHidden = true
        
        navigationController?.hidesBarsOnSwipe = true
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        performSelector(inBackground: #selector(loadData), with: nil)
    }
    
    // number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number of rows in section
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
        cell.date.text = "\(filteredItems[indexPath.row].date)"
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for categories button
    @objc func categoriesTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "categoryTableView") {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set action for search button
    @objc func searchTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "searchTableView") as? SearchTableView {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // refresh collection view before view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideButtons()
        collectionView.reloadData()
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        print("Refresh!")
        
        filteredItems.shuffle()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // show or hide filter and sort buttons
    func hideButtons() {
        if isFilterApplied {
            filterButton.isHidden = false
            sortButton.isHidden = false
        } else {
            filterButton.isHidden = true
            sortButton.isHidden = true
        }
    }
    
    // load data in the background
    @objc func loadData() {
        for _ in 0...3 {
            let tesla = Item(category: "Vehicles", subCategory: "Cars", title: "Tesla Model X", price: 6000, location: "London", date: Date())
            let bmw = Item(category: "Vehicles", subCategory: "Cars", title: "BMW E36 2.0 LPG", price: 500, location: "Stirling", date: Date())
            let fiat = Item(category: "Vehicles", subCategory: "Cars", title: "Fiat 1.9 TDI", price: 1200, location: "Glasgow", date: Date())
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
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Highest price", style: .default) { [weak self] _ in
            filteredItems.sort(by: {$0.price > $1.price})
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Date added", style: .default) { [weak self] _ in
            filteredItems.sort(by: {$0.date < $1.date})
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}

