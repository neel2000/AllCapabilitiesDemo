//
//  MapViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 11/08/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        view.addSubview(mapView)
        
        // Set a location (e.g., New York City)
        let location = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        mapView.mapType = .standard
    }
}
