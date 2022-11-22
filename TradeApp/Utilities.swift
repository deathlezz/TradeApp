//
//  Utilities.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import Foundation

// date formatter extension
extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter.string(from: self)
    }
}

// categories array
let categories = ["All Ads", "Vehicles", "Real Estate", "Job", "Home", "Electronics", "Fashion", "Agriculture", "Animals", "For Kids", "Sport & Hobby", "Music", "For Free"]
