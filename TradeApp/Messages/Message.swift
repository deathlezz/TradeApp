//
//  Message.swift
//  TradeApp
//
//  Created by deathlezz on 23/05/2023.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    func toAnyObject() -> [String: Any] {
        return [
            "sender": sender.senderId,
            "messageId": messageId,
            "sentDate": sentDate.toString(shortened: false),
            "kind": kind.getMessageText()
        ]
    }
}
