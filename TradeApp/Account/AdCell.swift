//
//  AdCell.swift
//  TradeApp
//
//  Created by deathlezz on 04/03/2023.
//

import UIKit

class AdCell: UITableViewCell {
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var availability: UILabel!
    @IBOutlet var views: UIButton!
    @IBOutlet var saved: UIButton!
    @IBOutlet var stateButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnail.image = thumbnail.image?.resized(to: thumbnail.frame.size)
    }
}
