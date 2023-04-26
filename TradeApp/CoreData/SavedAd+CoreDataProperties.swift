//
//  SavedAd+CoreDataProperties.swift
//  TradeApp
//
//  Created by deathlezz on 26/04/2023.
//
//

import Foundation
import CoreData


extension SavedAd {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedAd> {
        return NSFetchRequest<SavedAd>(entityName: "SavedAd")
    }

    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var price: Int32
    @NSManaged public var location: String?
    @NSManaged public var date: Date?

}

extension SavedAd : Identifiable {

}
