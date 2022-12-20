//
//  ItemView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class ItemView: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
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
        
        scrollView.isPagingEnabled = true
        
        for i in 0..<imgs.count {
            let imageView = UIImageView()
            imageView.image = imgs[i]
            imageView.contentMode = .scaleAspectFit
            let xPosition = view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: -100, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
            
        }
        
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
        
//        scrollView.addGestureRecognizer(leftSwipe)
//        scrollView.addGestureRecognizer(rightSwipe)
    }
    
    // set swipe recognizer
    @objc func getSwipeAction(_ recognizer: UISwipeGestureRecognizer) {
        
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
        
//        imageView.image = imgs[currentImage]
    }

}
