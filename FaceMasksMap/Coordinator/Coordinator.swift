//
//  Coordinator.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import CoreLocation

protocol Coordinator {
    func start()
}

class AppCoordinator: Coordinator {
    
    private var window: UIWindow?
 
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let mainCtrl = MapViewController(locationFetch: LocationFetcher(locationManager: CLLocationManager()))
        self.window?.rootViewController = UINavigationController(rootViewController: mainCtrl)
        self.window?.makeKeyAndVisible()
    }
}

