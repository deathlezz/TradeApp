//
//  CollectionTableViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 10/12/2022.
//

import UIKit

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // set number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    // set table view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotosCell {
            cell.layer.cornerRadius = 10
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}
