//
//  SavedAd+CoreDataProperties.swift
//  TradeApp
//
//  Created by deathlezz on 25/04/2023.
//
//

import Foundation
import CoreData


extension SavedAd {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedAd> {
        return NSFetchRequest<SavedAd>(entityName: "SavedAd")
    }

    @NSManaged public var date: Date?
    @NSManaged public var location: String?
    @NSManaged public var photos: Data?
    @NSManaged public var price: Int32
    @NSManaged public var title: String?
    @NSManaged public var views: Int32
    @NSManaged public var saved: Int32
    @NSManaged public var long: Double
    @NSManaged public var lat: Double
    @NSManaged public var itemDescription: String?
    @NSManaged public var id: Int32
    @NSManaged public var category: String?

}

extension SavedAd : Identifiable {

}
