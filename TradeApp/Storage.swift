//
//  Storage.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation
import UIKit

class Storage {
    static let shared = Storage()
    var items = [Item]()
    var filteredItems = [Item]()
    var recentlyAdded = [Item]()
    var users = [User]()
}
