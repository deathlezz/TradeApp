//
//  User.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import Foundation

struct User: Codable {
    var items = [Item?]()
    var mail: String?
    var password: String?
    var phoneNumber: Int?
}
