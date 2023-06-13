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
    var mail: String?
    var password: String?
    var phoneNumber: Int?
    
    func toAnyObject() -> [String: Any] {
        
        var active = [Any]()
        var ended = [Any]()
        var conversations = [String: [[String: Any]]]()
    
        for chat in chats {
            
            conversations[chat.key] = []
            
            for message in chat.value {
                let msg: [String: Any] = [
//                    "sender": "\(message.sender)",
                    "messageId": message.messageId,
                    "sentDate": message.sentDate.formatDate(),
//                    "kind": "\(message.kind)"
                ]
                
                conversations[chat.key]?.append(msg)
            }
        }
        
        for item in activeItems {
            let dictionary: [String: Any] = [
                "photos": item?.photos,
                "title": item?.title,
                "price": item?.price
            ]
            
            active.append(dictionary)
        }
        
        for item in endedItems {
            let dictionary: [String: Any] = [
                "photos": item?.photos,
                "title": item?.title,
                "price": item?.price
            ]
            
            ended.append(dictionary)
        }
        
            
        return [
            "activeItems": active,
            "endedItems": ended,
            "chats": conversations,
            "password": password,
            "phoneNumber": phoneNumber
        ]
        
    }
}
