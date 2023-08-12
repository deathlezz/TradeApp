//
//  Storage.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation
import UIKit

class AppStorage {
    static let shared = AppStorage()
    var items = [Item]()
    var filteredItems = [Item]()
    var recentlyAdded = [Item]()
}
