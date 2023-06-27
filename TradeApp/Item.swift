//
//  Item.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation

struct Item {
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
    var owner: String
    
    // convert custom model to Any object
    func toAnyObject(urls: [String: String]) -> [String: Any] {
        return [
            "photos": urls,
            "title": title,
            "price": price,
            "category": category!,
            "location": location,
            "description": description!,
            "date": date.toString(shortened: false),
            "views": views!,
            "saved": saved!,
            "lat": lat!,
            "long": long!,
            "id": id,
            "owner": owner
        ]
    }
}
