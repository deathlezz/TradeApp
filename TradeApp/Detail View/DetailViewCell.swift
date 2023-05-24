//
//  DetailViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 25/12/2022.
//

import UIKit

protocol Index {
    func pushIndex(index: Int)
}

class DetailViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
        
    @IBOutlet var collectionView: UICollectionView!
    
    var imgs = [UIImage?]()
    var delegate: Index?
    var currentImage = 0
    
    override func awakeFromNib() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(getIndex), name: NSNotification.Name("getIndex"), object: nil)
    }
    
    // set number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    // set number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // set collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailViewCell", for: indexPath) as? PhotosCell {
            cell.imageView.image = imgs[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // set action for tapped cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pushIndex(index: indexPath.item)
    }
    
    // get current image index
    @objc func getIndex(_ notification: Notification) {
        currentImage = notification.userInfo?["index"] as! Int
        scrollToItem()
    }
    
    // scroll to item before view appeared
    func scrollToItem() {
        let indexPath = IndexPath(item: currentImage, section: 0)
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.isPagingEnabled = true
    }
    
}
