//
//  Storage.swift
//  TradeApp
//
//  Created by deathlezz on 19/11/2022.
//

import Foundation

var items = [Item]()
var filteredItems = [Item]()
var recentlyAdded = [Item]()
var recentlySearched = [String]()
var savedItems = [Item]()
var isFilterApplied = false
var currentFilters = [String: String]()
var filterArray = [Item]()
