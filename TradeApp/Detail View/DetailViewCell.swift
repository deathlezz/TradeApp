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

class DetailViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    @IBOutlet var collectionView: UICollectionView!
    
    var imgs = [UIImage]()
    var delegate: Index?
    var currentImage = 0
    
    override func awakeFromNib() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(getIndex), name: NSNotification.Name("getIndex"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeImages), name: NSNotification.Name("removeImages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateImages), name: NSNotification.Name("updateImages"), object: nil)
        
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
//            cell.imageView.image = nil
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
        guard imgs.count > currentImage else { return }
        let indexPath = IndexPath(item: currentImage, section: 0)
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.isPagingEnabled = true
    }
    
    // set scalable size for item cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    // remove images before view dissappear to release memory
    @objc func removeImages() {
        imgs.removeAll(keepingCapacity: false)
    }
    
    // update images after downloading from firebase
    @objc func updateImages(_ notification: Notification) {
        let images = notification.userInfo?["images"] as! [UIImage]
        imgs.removeAll(keepingCapacity: false)
        imgs = images
        collectionView.reloadData()
    }
    
    // convert URLs into images
    func convertImages(urls: [String], completion: @escaping ([UIImage]) -> Void) {
        guard urls.count > 1 else { return }
        
        var imagesDict = [String: UIImage]()
        
        // get all images except the thumbnail
        let links = urls.map {URL(string: $0)}.dropFirst()
        
        for (index, url) in links.enumerated() {
            let task = URLSession.shared.dataTask(with: url!) { (data, _, _) in
                if let data = data {
                    let image = UIImage(data: data) ?? UIImage()
                    imagesDict["image\(index)"] = image
                }

                guard imagesDict.count == links.count else { return }
                let sorted = imagesDict.sorted {$0.key < $1.key}
                let images = Array(sorted.map {$0.value})
                imagesDict.removeAll(keepingCapacity: false)
                completion(images)
            }

            task.resume()
        }
    }
}
