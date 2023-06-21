//
//  FirebaseItem.swift
//  TradeApp
//
//  Created by deathlezz on 21/06/2023.
//

import Foundation

struct FirebaseItem: Codable {
    var photos: [String]
    var title: String
    var price: Int
    var category: String
    var location: String
    var description: String
    var date: String
    var views: Int
    var saved: Int
    var lat: Double
    var long: Double
    var id: Int
}
