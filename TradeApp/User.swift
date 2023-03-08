//
//  User.swift
//  TradeApp
//
//  Created by deathlezz on 08/03/2023.
//

import Foundation

struct User: Codable {
    var items = [Item]()
    let mail: String
    let password: String
    let phoneNumber: Int
}
