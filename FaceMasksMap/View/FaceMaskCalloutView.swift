//
//  FaceMaskCalloutView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/13.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import MapKit

class FaceMaskCalloutView: UIView {

    var annotation: FaceMaskAnnotation?
    
    private var nameLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .center
    }
    
    private var addressLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.numberOfLines = 2
    }
    
    private var phoneLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private var adultLabel = UILabel {
        $0.text = "成人口罩剩餘數量"
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private var adultCountLabel = UILabel {
        $0.text = "-"
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textColor = .lightGray
    }
    
    private var childLabel = UILabel {
        $0.text = "兒童口罩剩餘數量"
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private var childCountLabel = UILabel {
        $0.text = "-"
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textColor = .lightGray
    }
    
    
    init(annotation: MKAnnotation) {
        self.annotation = annotation as? FaceMaskAnnotation
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.setViews()
        self.updateContents(for: self.annotation)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setViews() {
        self.addSubview(nameLabel)
        self.addSubview(addressLabel)
        self.addSubview(phoneLabel)
        self.addSubview(adultLabel)
        self.addSubview(adultCountLabel)
        self.addSubview(childLabel)
        self.addSubview(childCountLabel)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
        }
        
        self.addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
            make.right.equalTo(self.nameLabel)
        }
        
        self.phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.addressLabel)
            make.top.equalTo(self.addressLabel.snp.bottom).offset(4)
        }
        
        self.adultLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.phoneLabel.snp.bottom).offset(8)
        }
        
        self.adultCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.adultLabel)
            make.top.equalTo(self.adultLabel.snp.bottom).offset(4)
        }
        
        self.childLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.adultCountLabel.snp.bottom).offset(8)
        }
        
        self.childCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.childLabel)
            make.top.equalTo(self.childLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    private func updateContents(for annotation: FaceMaskAnnotation?) {
        self.nameLabel.text = annotation?.propertie?.name
        self.addressLabel.text = annotation?.propertie?.address
        self.phoneLabel.text = annotation?.propertie?.phone
        self.adultCountLabel.text = "\(annotation?.propertie?.adult ?? 0)"
        self.childCountLabel.text = "\(annotation?.propertie?.child ?? 0)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
