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
    var items = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for _ in 0...20 {
            items.append("ABC")
        }
        
        categoriesButton = UIBarButtonItem(image: .init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(categoriesTapped))
        
        searchButton = UIBarButtonItem(image: .init(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        
        navigationItem.leftBarButtonItem = categoriesButton
        navigationItem.rightBarButtonItem = searchButton
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        
        cell.titleLabel.text = items[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .gray
        
        return cell
    }
    
    @objc func categoriesTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "categoryTableView") {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func searchTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "searchHistoryTableView") {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

