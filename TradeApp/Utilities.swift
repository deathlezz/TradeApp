//
//  Utilities.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import Foundation
import UIKit

// date formatter extension
extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension UIViewController {
    func embedInNavController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}

// categories array
let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]

// manage filters function
func manageFilters() {
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
