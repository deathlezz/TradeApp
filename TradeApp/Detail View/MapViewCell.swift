//
//  MapViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 30/12/2022.
//

import UIKit
import MapKit
import CoreLocation

protocol Coordinates {
    func pushCoords(_ lat: Double, _ long: Double)
    func pushDistance(_ string: String)
}

class MapViewCell: UITableViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var delegate: Coordinates?
    var didGeocode: Bool!
    var locationManager: CLLocationManager!
    var item: CLLocation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        didGeocode = false
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeMap), name: NSNotification.Name("removeMap"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(restoreMap), name: NSNotification.Name("restoreMap"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pushLocation), name: NSNotification.Name("pushLocation"), object: nil)
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
            guard let itemLocation = item else { return }
            
            delegate?.pushCoords(itemLocation.coordinate.latitude, itemLocation.coordinate.longitude)

            let distance = itemLocation.distance(from: location) / 1000
            let rounded = String(format: "%.0f", distance)
            let string = "\(rounded) km from you"
            distanceLabel.text = string

            delegate?.pushDistance(string)
        }
    }

    // catch user location erorrs
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // change string into coordinates
    func forwardGeocoding(address: String) {
        if didGeocode == false {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { [weak self] (placemarks, error) in
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
                    let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7))
                    
                    self?.mapView.setRegion(region, animated: false)
                    self?.didGeocode = true
                    
                    let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self?.item = itemLocation
                    self?.locationManager.requestLocation()
                    
                } else {
                    print("No matching location found")
                }
            })
        }
    }
    
    // remove map before view disappeared to avoid memory leak
    @objc func removeMap() {
        mapView.removeFromSuperview()
        mapView = nil
    }
    
    // restore map before view appeared
    @objc func restoreMap() {
        if mapView == nil {
            mapView = MKMapView()
            superview?.addSubview(mapView)
        }
    }
    
    // get location info
    @objc func pushLocation(_ notification: NSNotification) {
        guard let location = notification.userInfo!["location"] as? String else {
            print("Could not find location")
            return
        }

        forwardGeocoding(address: location)
    }

}
