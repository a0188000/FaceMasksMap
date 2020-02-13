//
//  SingleAnnotationView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/12.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit
import CCHMapClusterController

class SingleAnnotationView: MKAnnotationView {

    var propertie: Propertie? {
        didSet { 
            self.setNeedsLayout()
        }
    }
    
    weak var calloutView: FaceMaskCalloutView?
    
    private(set) var animationDuration: TimeInterval = 0.25
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
        }
    }
    
    private var faceMaskCountLabel = UILabel {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 2
        $0.numberOfLines = 1
        $0.font = .boldSystemFont(ofSize: 12)
        $0.baselineAdjustment = .alignCenters
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .init(width: 0.5, height: 0.5)
        
        self.addSubview(self.faceMaskCountLabel)
        self.faceMaskCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let adult = (self.annotation as? FaceMaskAnnotation)?.propertie?.adult.calculatePercentage(denominator: 200) else { return }
        switch adult {
        case 51...:     self.image = UIImage(named: "pin-green")
        case 21...50:   self.image = UIImage(named: "pin-orange")
        case 1...20:    self.image = UIImage(named: "pin-red")
        default:        self.image = UIImage(named: "pin-gray")
        }
        self.faceMaskCountLabel.text = "\(adult)%"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            guard let ann = self.annotation as? FaceMaskAnnotation else { return }
            let calloutView = FaceMaskCalloutView(annotation: ann)
            calloutView.alpha = 0
            self.calloutView = calloutView
            self.addSubview(calloutView)
            calloutView.snp.makeConstraints { (make) in
                make.width.equalTo(260)
                make.bottom.equalTo(self.snp.top)
                make.centerX.equalToSuperview().offset(self.calloutOffset.x)
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.calloutView?.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.calloutView?.alpha = 0
            }, completion: { _ in
                self.calloutView?.removeFromSuperview()
            })
        }
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
