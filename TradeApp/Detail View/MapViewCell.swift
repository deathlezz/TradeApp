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
        
        NotificationCenter.default.addObserver(self, selector: #selector(setLocation), name: NSNotification.Name("setLocation"), object: nil)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.delegate = self
                self?.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    @objc func setLocation(_ notification: NSNotification) {

        guard let city = notification.userInfo?["location"] as? String else { return }
        
        locationManager.getLocation(place: city) { location in
            guard let location = location else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.mapView.setRegion(region, animated: true)
            
            let itemLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            self.item = itemLocation
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .denied {
            
            guard let coordinates: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            
            let userLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            
            let distance = userLocation.distance(from: item)
            print("\(distance / 1000) km")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = userLocation.distance(from: item)
        print("\(distance / 1000) km from you")
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
