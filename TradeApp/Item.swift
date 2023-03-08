//
//  Item.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation

struct Item: Codable {
    let photos: [Data?]
    let title: String
    let price: Int
    let category: String
    let location: String
    let description: String
    let date: Date
    var views: Int
    var saved: Int
    let lat: Double
    let long: Double
//    let itemID: Int
}
