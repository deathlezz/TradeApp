//
//  ItemViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 24/12/2022.
//

import UIKit

class ItemViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        imageView.addGestureRecognizer(pinch)
        imageView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetZoom), name: NSNotification.Name("resetZoom"), object: nil)
    }
    
    // pinch to zoom
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1, scale.a < 5, scale.d < 5 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    // reset imageView zoom
    @objc func resetZoom(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.transform = CGAffineTransform.identity
        })
    }
    
    // set scalable size for item cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
}
