//
//  User.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import Foundation
import MessageKit

struct User {
    var activeItems = [Item?]()
    var endedItems = [Item?]()
    var chats = [String: [MessageType]]()
    var mail: String
    var password: String
    var phoneNumber: Int?
    
    func toAnyObject() -> [String: Any] {
        
        return [
            "mail": mail,
            "password": password
        ]
        
    }
}
