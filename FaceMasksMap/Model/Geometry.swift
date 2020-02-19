//
//  Geometry.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit

struct Geometry: Codable {
    var type: String
    var coordinates: [Double]
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = self.coordinates.last, let lon = self.coordinates.first else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
