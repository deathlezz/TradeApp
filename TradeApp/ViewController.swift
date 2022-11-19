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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for _ in 0...3 {
            let tesla = Item(category: "Vehicles", title: "Tesla Model X", price: "£6000", location: "London", date: "Today at 21:37")
            let bmw = Item(category: "Vehicles", title: "BMW E36 2.0 LPG", price: "£500", location: "Stirling", date: "Yesterday at 00:07")
            items.append(tesla)
            items.append(bmw)
        }
        
        filteredItems = items
        
        categoriesButton = UIBarButtonItem(image: .init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(categoriesTapped))
        
        searchButton = UIBarButtonItem(image: .init(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        
        navigationItem.leftBarButtonItem = categoriesButton
        navigationItem.rightBarButtonItem = searchButton
        
        navigationController?.hidesBarsOnSwipe = true
        
        // pull to reset searching
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(resetSearch), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
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
        cell.price.text = filteredItems[indexPath.row].price
        cell.location.text = filteredItems[indexPath.row].location
        cell.date.text = filteredItems[indexPath.row].date
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
        if let vc = storyboard?.instantiateViewController(withIdentifier: "searchTableView") {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // refresh collection view after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    // set action for "pull to reset"
    @objc func resetSearch(refreshControl: UIRefreshControl) {
        print("Reset!")
        filteredItems = items
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
}

