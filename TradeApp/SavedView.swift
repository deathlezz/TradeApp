//
//  SavedView.swift
//  TradeApp
//
//  Created by deathlezz on 26/11/2022.
//

import UIKit

class SavedView: UICollectionViewController {
    
    var savedItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Remove all", style: .plain, target: self, action: #selector(removeAllTapped))

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
            vc.item = savedItems[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
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
        collectionView.reloadData()
    }

    @objc func removeAllTapped() {
        guard !savedItems.isEmpty else { return }
        savedItems.removeAll()
        collectionView.reloadData()
        Utilities.saveItems(savedItems)
    }
}
