//
//  Item.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation
import UIKit

struct Item {
    var thumbnail: UIImage?
    var photosURL: [String]
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
    func toAnyObject() -> [String: Any] {
        return [
            "photosURL": photosURL,
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
