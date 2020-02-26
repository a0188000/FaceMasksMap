//
//  FaceMasksBaseAnnotationView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import MapKit
import CCHMapClusterController

class FaceMasksBaseAnnotationView: MKAnnotationView {
    
    var calloutView: FaceMaskCalloutView?
    var uniqueLocation: Bool = false
    
    var faceMaskCountLabel = UILabel {
        if #available(iOS 11.0, *) {
            $0.textColor = UIColor(named: "CountColor")
        } else {
            $0.textColor = .black
        }
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 2
        $0.numberOfLines = 1
        $0.font = .boldSystemFont(ofSize: 10)
        $0.baselineAdjustment = .alignCenters
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.anchorPoint = .init(x: 0.5, y: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            
        } else {
            self.calloutView?.removeFromSuperview()
        }
    }
    
    func setImageAndPercentage() {
        var count = 0
        var denominator: CGFloat = 200
        if let clusterAnnotation = self.annotation as? CCHMapClusterAnnotation {
            let annotations = clusterAnnotation.annotations.compactMap { $0 as? FaceMaskAnnotation }
            guard
                let faceMasksAnn = annotations.first,
                let propertie = annotations.first?.propertie
            else { return }
            switch faceMasksAnn.faceMasksType {
            case .adult: count = propertie.adult
            case .child:
                count = propertie.child
                denominator = 50
            }
        } else if let faceMasksAnn = self.annotation as? FaceMaskAnnotation {
            guard let propertie = faceMasksAnn.propertie else { return }
            switch faceMasksAnn.faceMasksType {
            case .adult: count = propertie.adult
            case .child:
                count = propertie.child
                denominator = 50
            }
        }

        count = count.calculatePercentage(denominator: denominator)
        switch count {
        case 51...:     self.image = UIImage(named: "pin-green")
        case 21...50:   self.image = UIImage(named: "pin-orange")
        case 1...20:    self.image = UIImage(named: "pin-red")
        default:        self.image = UIImage(named: "pin-gray")
        }
        self.faceMaskCountLabel.text = "\(count > 100 ? 100 : count)%"
        self.faceMaskCountLabel.adjustsFontSizeToFitWidth = true
//        self.faceMaskCountLabel.sizeToFit()
    }
}
