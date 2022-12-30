//
//  MapViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 30/12/2022.
//

import UIKit
import MapKit

extension CLLocationManager {
    func getLocation(forPlaceCalled name: String,
                         completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
//            guard error == nil else {
//                print("*** Error in \(#function): \(error!.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let placemark = placemarks?[0] else {
//                print("*** Error in \(#function): placemark is nil")
//                completion(nil)
//                return
//            }
            
            guard let location = placemarks?[0].location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}

class MapViewCell: UITableViewCell, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        locationManager = CLLocationManager()
        
        setLocation()
    }
    
    func setLocation() {
        
        let city = "London"
        
        locationManager.getLocation(forPlaceCalled: city) { location in
            guard let location = location else { return }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.mapView.setRegion(region, animated: true)
        }
    }

}
