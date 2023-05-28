//
//  Utilities.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

// date formatter extension
extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter.string(from: self)
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
    
    // city name validation
    static func isCityValid(_ city: String, completion: @escaping (Bool) -> Void) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "en")
        geocoder.geocodeAddressString(city, in: nil, preferredLocale: locale, completionHandler: { (placemarks, error) in
            
            if error != nil {
                completion(false)
                return
            }
            
            placemarks?.forEach { (placemark) in
                if placemark.locality != city {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        })
    }
    
    // change city name to coordinates
    static func forwardGeocoding(address: String, completion: @escaping (Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "en")
        geocoder.geocodeAddressString(address, in: nil, preferredLocale: locale, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Failed to retrieve location")
                return
            }
            
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                completion(coordinate.latitude, coordinate.longitude)
                
            } else {
                print("No matching location found")
            }
        })
    }
    
    // set logged user
    static func setUser(_ user: String?) {
        if user != nil {
            KeychainWrapper.standard.set(user!, forKey: "loggedUser")
        } else {
            KeychainWrapper.standard.removeObject(forKey: "loggedUser")
        }
    }
    
    // load logged user
    static func loadUser() -> String? {
        if let user = KeychainWrapper.standard.string(forKey: "loggedUser") {
            return user
        } else {
            return nil
        }
    }
    
    // load distance measurement unit
    static func loadDistanceUnit() -> String {
        let defaults = UserDefaults.standard
        if let unit = defaults.object(forKey: "DistanceUnit") as? String {
            return unit
        } else {
            return "mi"
        }
    }
    
    // save saved items
    static func saveItem(_ item: Item) {
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        
        let newAd = NSEntityDescription.insertNewObject(forEntityName: "SavedAd", into: managedContext)
        newAd.setValue(item.photos[0], forKey: "image")
        newAd.setValue(item.title, forKey: "title")
        newAd.setValue(item.price, forKey: "price")
        newAd.setValue(item.location, forKey: "location")
        newAd.setValue(item.date, forKey: "date")
        newAd.setValue(item.id, forKey: "id")

        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        print("Item saved")
    }
    
    // remove saved items
    static func removeItems(_ items: [Item]) {
        let adsFetch: NSFetchRequest<SavedAd> = SavedAd.fetchRequest()
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        
        do {
            let results = try managedContext.fetch(adsFetch)
            
            for result in results {
                for item in items {
                    if result.id == item.id {
                        print("Removed: \(result.id)")
                        managedContext.delete(result)
                        break
                    }
                }
            }
            
        } catch let error as NSError {
            print("Delete error: \(error) description: \(error.userInfo)")
        }

        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
    }
    
    // load saved items
    static func loadItems() -> [Item] {
        let adsFetch: NSFetchRequest<SavedAd> = SavedAd.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        adsFetch.sortDescriptors = [sortByDate]
        
        do {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let results = try managedContext.fetch(adsFetch)
            
            var items = [Item]()
            
            for result in results {
                let item = Item(photos: [result.image], title: result.title!, price: Int(result.price), location: result.location!, date: result.date!, id: Int(result.id))
                items.append(item)
            }
            return items

        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
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
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.location == currentLocation}
        }
        
        // price filter
        if currentPriceFrom != nil && currentPriceTo != nil {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price >= Int(currentPriceFrom!)! && $0.price <= Int(currentPriceTo!)!}
        } else if currentPriceFrom != nil {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price >= Int(currentPriceFrom!)!}
        } else if currentPriceTo != nil {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price <= Int(currentPriceTo!)!}
        }
        
        // sort filter
        if currentSort != nil {
            if currentSort == "Lowest price" {
                Storage.shared.filteredItems.sort(by: {$0.price < $1.price})
            } else if currentSort == "Highest price" {
                Storage.shared.filteredItems.sort(by: {$0.price > $1.price})
            } else if currentSort == "Date added" {
                Storage.shared.filteredItems.sort(by: {$0.date < $1.date})
            }
        }
    }
    
}
