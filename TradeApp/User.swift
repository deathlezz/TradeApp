//
//  User.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import Foundation

struct User: Codable {
    var activeItems = [Item?]()
    var endedItems = [Item?]()
    var messages = [Message?]()
    var mail: String?
    var password: String?
    var phoneNumber: Int?
}
