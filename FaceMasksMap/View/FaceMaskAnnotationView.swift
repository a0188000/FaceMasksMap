//
//  FaceMaskAnnotationView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/11.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import MapKit
import SnapKit
import CCHMapClusterController

class FaceMaskAnnotationView: MKAnnotationView {
    
    weak var calloutView: FaceMaskCalloutView?
    
    var count: Int = 1 {
        didSet {
            self.faceMaskCountLabel.isHidden = count != 1
            self.countLabel.isHidden = count == 1
            self.countLabel.text = "\(count)"
            self.setNeedsLayout()
        }
    }
    
    private var countLabel = UILabel {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 2
        $0.numberOfLines = 1
        $0.font = .boldSystemFont(ofSize: 12)
        $0.baselineAdjustment = .alignCenters
        $0.isHidden = true
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
        $0.isHidden = true
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .init(width: 0.5, height: 0.5)
    
        self.setViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected && count == 1 {
            guard let clusterAnn = self.annotation as? CCHMapClusterAnnotation else { return }
            let annotations = clusterAnn.annotations.compactMap { $0 as? FaceMaskAnnotation }
            guard let ann = annotations.first else { return }
            self.addCalloutView(annotation: ann)
        } else {
            self.removeCalloutView()
        }
        self.layoutSubviews()
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.count == 1 {
//            self.image = UIImage(named: "faceMaskPin")
            self.configureAnnotationImage()
        } else {
            self.image = UIView {
                $0.frame = .init(x: 0, y: 0, width: 40, height: 40)
                $0.backgroundColor = self.isSelected ? UIColor(red: 0.41, green: 0.54, blue: 0.95, alpha: 1) : UIColor(red: 0.14, green: 0.80, blue: 0.46, alpha: 1)
                $0.layer.cornerRadius = 20
                $0.clipsToBounds = true
            }.asImage()
        }
    }
    
    private func setViews() {
        self.addSubview(self.countLabel)
        self.countLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.faceMaskCountLabel)
        self.faceMaskCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureAnnotationImage() {
        guard let clusterAnn = self.annotation as? CCHMapClusterAnnotation else { return }
        let annotations = clusterAnn.annotations.compactMap { $0 as? FaceMaskAnnotation}
        guard let adult = annotations.first?.propertie?.adult.calculatePercentage(denominator: 200) else { return }
        switch adult {
        case 51...:     self.image = UIImage(named: "pin-green")
        case 21...50:   self.image = UIImage(named: "pin-orange")
        case 1...20:    self.image = UIImage(named: "pin-red")
        default:        self.image = UIImage(named: "pin-gray")
        }
        self.faceMaskCountLabel.text = "\(adult)%"
    }
    
    private func addCalloutView(annotation: MKAnnotation) {
        let calloutView = FaceMaskCalloutView(annotation: annotation)
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
    }
    
    private func removeCalloutView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.calloutView?.alpha = 0
        }, completion: { _ in
            self.calloutView?.removeFromSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
