//
//  ItemView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class ItemView: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var imgs = [UIImage?]()
    var item: Item!
    var transition = CATransition()
    
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
        var direction: CATransitionSubtype
        
        if recognizer.direction == .left {
            print("Left swipe")
            currentImage += 1
            direction = .fromRight
        } else {
            print("Right swipe")
            currentImage -= 1
            direction = .fromLeft
        }
        
        if currentImage > imgs.count - 1 {
            currentImage = imgs.count - 1
            return
        } else if currentImage < 0 {
            currentImage = 0
            return
        }
        
        animateImageView(direction: direction)
//        imageView.image = imgs[currentImage]
    }
    
    // animate swipe gesture
    func animateImageView(direction: CATransitionSubtype) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        
        transition.type = CATransitionType.push
        transition.subtype = direction
        
        imageView.layer.add(transition, forKey: kCATransition)
        imageView.image = imgs[currentImage]
        CATransaction.commit()
    }

}
