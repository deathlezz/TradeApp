//
//  Utilities.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter.string(from: self)
    }
}
