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
    var image: UIImage = UIImage()
    
    init(coordinate: CLLocationCoordinate2D, propertie: Propertie, faceMaskType: FaceMaskType) {
        super.init()
        self.coordinate = coordinate
        self.propertie = propertie
        let testView = UIView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        testView.backgroundColor = .blue
        let label = UILabel(frame: testView.frame)
//        label.text = faceMaskType == .adult ? "\(propertie.adult)" : "\(propertie.child)"
        label.textAlignment = .center
        testView.addSubview(label)
        testView.layer.cornerRadius = 16.5
        testView.clipsToBounds = true
//        self.image = testView.asImage()
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
