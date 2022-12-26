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
        navigationController?.isToolbarHidden = true
    }
    
    // set number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemViewCell", for: indexPath) as? ItemViewCell {

            cell.imageView.image = imgs[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // update current image index
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        var index = Int(ceil(x / width))
        
        if index < 0 {
            index = 0
        } else if index > imgs.count - 1 {
            index = imgs.count - 1
        }
        
        currentImage = index
        NotificationCenter.default.post(name: NSNotification.Name("resetZoom"), object: nil)
    }
    
    // scroll to current image before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: currentImage, section: 0), at: .centeredHorizontally, animated: false)
        collectionView.isPagingEnabled = true
    }
    
    // get index before view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name("getIndex"), object: nil, userInfo: ["index": currentImage!])
    }
    
}
