//
//  Item.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation

struct Item: Codable {
    var photos: [Data?]
    var title: String
    var price: Int
    var category: String?
    var location: String
    var description: String?
    var date: Date
    var views: Int?
    var saved: Int?
    var lat: Double?
    var long: Double?
    var id: Int
    
    // function for saving data
    func toAnyObject() -> [String: Any] {
        return [
            "photos": photos,
            "title": title,
            "price": price,
            "category": category,
            "location": location,
            "description": description,
            "date": date,
            "views": views,
            "saved": saved,
            "lat": lat,
            "long": long,
            "id": id
        ]
     }
}
