//
//  Utilities.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import Foundation
import UIKit
import CoreLocation

// date formatter extension
extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func isValid() -> Bool {
        var result = true
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self, completionHandler: { (placemarks, error) in
            if error != nil {
                print("invalid location")
                result = false
            }
        })
        
        return result
    }
}

// rotate image extension
extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

class Utilities {
    
    // save saved items
    static func saveItems(_ items: [Item]) {
        let jsonEncoder = JSONEncoder()
        
        if let savedItems = try? jsonEncoder.encode(items) {
            let defaults = UserDefaults.standard
            defaults.set(savedItems, forKey: "savedItems")
        } else {
            print("Failed to save items.")
        }
    }
    
    // load saved items
    static func loadItems() -> [Item] {
        let defaults = UserDefaults.standard
        if let savedItems = defaults.object(forKey: "savedItems") as? Data {
            let jsonDecoder = JSONDecoder()
            
            if let decodedItems = try? jsonDecoder.decode([Item].self, from: savedItems) {
                return decodedItems
            } else {
                print("Failed to load items.")
            }
        }
        return [Item]()
    }
    
    // save applied filters
    static func saveFilters(_ filters: [String: String]) {
        let defaults = UserDefaults.standard
        defaults.set(filters, forKey: "currentFilters")
    }
    
    // load applied filters
    static func loadFilters() -> [String: String] {
        let defaults = UserDefaults.standard
        if let filters = defaults.object(forKey: "currentFilters") as? [String: String] {
            return filters
        }
        return [String: String]()
    }
    
    // manage filters function
    static func manageFilters(_ currentFilters: [String: String]) {
        let currentLocation = currentFilters["Location"]
        let currentPriceFrom = currentFilters["PriceFrom"]
        let currentPriceTo = currentFilters["PriceTo"]
        let currentSort = currentFilters["Sort"]
        
        // location filter
        if currentLocation != nil {
            filteredItems = filteredItems.filter {$0.location == currentLocation}
        }
        
        // price filter
        if currentPriceFrom != nil && currentPriceTo != nil {
            filteredItems = filteredItems.filter {$0.price >= Int(currentPriceFrom!)! && $0.price <= Int(currentPriceTo!)!}
        } else if currentPriceFrom != nil {
            filteredItems = filteredItems.filter {$0.price >= Int(currentPriceFrom!)!}
        } else if currentPriceTo != nil {
            filteredItems = filteredItems.filter {$0.price <= Int(currentPriceTo!)!}
        }
        
        // sort filter
        if currentSort != nil {
            if currentSort == "Lowest price" {
                filteredItems.sort(by: {$0.price < $1.price})
            } else if currentSort == "Highest price" {
                filteredItems.sort(by: {$0.price > $1.price})
            } else if currentSort == "Date added" {
                filteredItems.sort(by: {$0.date < $1.date})
            }
        }
    }
}
