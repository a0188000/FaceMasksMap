//
//  FaceMaskAnnotation.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/11.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit

class FaceMaskAnnotation: MKPointAnnotation {
    
    var centerPoint: Bool = false
    var propertie: Propertie?
    var faceMasksType: FaceMasksType = .adult
    var image: UIImage = UIImage()
    var isFavorite: Bool = false
    
    init(coordinate: CLLocationCoordinate2D, propertie: Propertie, faceMaskType: FaceMasksType) {
        super.init()
        self.coordinate = coordinate
        self.propertie = propertie
        self.faceMasksType = faceMaskType
    }
 
    init(isCenter: Bool) {
        super.init()
    }
    
}

extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image {
                layer.render(in: $0.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
