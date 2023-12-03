//
//  Chat.swift
//  TradeApp
//
//  Created by deathlezz on 27/11/2023.
//

import Foundation
import UIKit

struct Chat {
    var messages: [Message]
    var itemId: String
    var itemOwner: String
    var buyer: String
    var title: String?
    var thumbnail: UIImage?
    
    func toAnyObject() -> [String: Any] {
//        let dict = ["0": messages[0].toAnyObject()] as! [String: [String: String]]
        
        return [
//            ["0": messages[0].toAnyObject()]
            "messages": ["m0": messages[0].toAnyObject()],
            "itemId": itemId,
            "itemOwner": itemOwner,
            "buyer": buyer
        ]
    }
}
