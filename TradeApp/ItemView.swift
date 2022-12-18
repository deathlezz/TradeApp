//
//  ItemView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class ItemView: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var currentImage: Int!
//    var selectedImage: UIImage!
    var selectedImageNumber: Int?
    var totalPictures: Int?
    
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "\(selectedImageNumber!) of \(totalPictures!)"
        navigationItem.largeTitleDisplayMode = .never
        
        let imgs = item.photos.map {UIImage(data: $0!)}
        imageView.image = imgs[currentImage]
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(leftSwipe)
        imageView.addGestureRecognizer(rightSwipe)
    }
    
    // set swipe recognizer
    @objc func getSwipeAction(_ recognizer: UISwipeGestureRecognizer) {
        let imgs = item.photos.map {UIImage(data: $0!)}
        
        if recognizer.direction == .left {
            print("Left swipe")
            currentImage += 1
        } else {
            print("Right swipe")
            currentImage -= 1
        }
        
        if currentImage > imgs.count - 1 {
            currentImage = imgs.count - 1
            return
        } else if currentImage < 0 {
            currentImage = 0
            return
        }
        imageView.image = imgs[currentImage]
    }

}
