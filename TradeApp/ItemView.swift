//
//  ItemView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class ItemView: UICollectionViewController {
    
    var imgs = [UIImage?]()
    var item: Item!
    
    var currentImage: Int! {
        didSet {
            title = "\(currentImage + 1) of \(imgs.count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "\(currentImage + 1) of \(imgs.count)"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        collectionView.isPagingEnabled = true
        navigationController?.isToolbarHidden = true
    }
    
    // set number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemViewCell", for: indexPath) as? PhotosCell {
            cell.imageView.image = imgs[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    // update current image index
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        currentImage = Int(ceil(x / width))
    }
    
    
}
