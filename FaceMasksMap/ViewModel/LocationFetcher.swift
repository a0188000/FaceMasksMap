//
//  LocationFetcher.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit

class LocationFetcher {
    var locationManager: CLLocationManager
    var userLocation: CLLocationCoordinate2D?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    func askAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
}
