//
//  Message.swift
//  TradeApp
//
//  Created by deathlezz on 04/05/2023.
//

import Foundation

struct Message: Codable {
    var thumbnail: Data
    var title: String
    var content: String
    var date: Date
}
