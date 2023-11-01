//
//  SavedAd+CoreDataProperties.swift
//  TradeApp
//
//  Created by deathlezz on 01/11/2023.
//
//

import Foundation
import CoreData


extension SavedAd {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedAd> {
        return NSFetchRequest<SavedAd>(entityName: "SavedAd")
    }

    @NSManaged public var date: String?
    @NSManaged public var id: Int32
    @NSManaged public var location: String?
    @NSManaged public var owner: String?
    @NSManaged public var photosURL: [String]?
    @NSManaged public var price: Int32
    @NSManaged public var thumbnail: Data?
    @NSManaged public var title: String?

}

extension SavedAd : Identifiable {

}
