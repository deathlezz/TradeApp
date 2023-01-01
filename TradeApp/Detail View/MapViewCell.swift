//
//  MapViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 30/12/2022.
//

import UIKit
import MapKit
import CoreLocation

extension CLLocationManager {
    func getLocation(place name: String, completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let location = placemarks?[0].location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}

class MapViewCell: UITableViewCell, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    var item: CLLocation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setLocation), name: NSNotification.Name("setLocation"), object: nil)
    }
    
    // set item location, center and zoom mapView
    @objc func setLocation(_ notification: NSNotification) {

        guard let city = notification.userInfo?["location"] as? String else { return }
        
        locationManager.getLocation(place: city) { location in
            guard let location = location else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            self.mapView.setRegion(region, animated: true)
            
            let itemLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            self.item = itemLocation
            self.locationManager.requestLocation()
        }
    }

    // set action for changed authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    // set action for updated user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Found user's location: \(location)")

            guard let itemLocation = item else { return }

            let distance = itemLocation.distance(from: location)
            print("\(distance / 1000) km from you")
        }
    }

    // catch user location erorrs
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

}
