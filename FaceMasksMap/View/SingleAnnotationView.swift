//
//  SingleAnnotationView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/12.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit
import CCHMapClusterController

class SingleAnnotationView: FaceMasksBaseAnnotationView {

    var propertie: Propertie? {
        didSet { 
            self.setNeedsLayout()
        }
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .init(width: 0.5, height: 0.5)
        
        self.addSubview(self.faceMaskCountLabel)
        self.faceMaskCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(28)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setImageAndPercentage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension Int {
    func calculatePercentage(denominator: CGFloat) -> Int {
        return Int((CGFloat(self) / denominator) * 100)
    }
}
