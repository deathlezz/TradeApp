//
//  NoConnectionView.swift
//  TradeApp
//
//  Created by deathlezz on 15/04/2023.
//

import UIKit

class NoConnectionView: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageView.image = UIImage(systemName: "wifi.slash")
        textLabel.text = "No Connection"
    }

}