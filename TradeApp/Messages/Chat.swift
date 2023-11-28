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
        return [
            "messages": messages.map {$0.toAnyObject()},
            "itemId": itemId,
            "itemOwner": itemOwner,
            "buyer": buyer
        ]
    }
}
