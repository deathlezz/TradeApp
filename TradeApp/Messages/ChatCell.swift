//
//  ChatCell.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2023.
//

import UIKit

class ChatCell: UITableViewCell {
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    // resize thumbnail
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnail.image = thumbnail.image?.resized(to: thumbnail.frame.size)
    }
}
