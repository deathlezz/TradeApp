//
//  ItemView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class ItemView: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: UIImage!
    var selectedImageNumber: Int?
    var totalPictures: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "\(selectedImageNumber!) of \(totalPictures!)"
        navigationItem.largeTitleDisplayMode = .never
        
        imageView.image = selectedImage
        
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
        if recognizer.direction == .left {
            print("Left swipe")
        } else if recognizer.direction == .right {
            print("Right swipe")
        }
    }

}
