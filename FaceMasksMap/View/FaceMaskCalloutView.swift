//
//  FaceMaskCalloutView.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/13.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import MapKit

protocol FaceMasksCalloutViewDelegate: class {
    func favoriteButtonPressed(at button: UIButton, annotation: FaceMaskAnnotation?)
}

class FaceMaskCalloutView: UIView {

    weak var delegate: FaceMasksCalloutViewDelegate?
    
    var annotation: FaceMaskAnnotation?
    
    private lazy var favoriteButton = UIButton {
        $0.setImage(UIImage(named: "favorite"), for: .normal)
        $0.setImage(UIImage(named: "favorite-highlight"), for: .selected)
        $0.addTarget(self, action: #selector(self.favoriteButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc private func favoriteButtonPressed(_ sender: UIButton) {
        self.delegate?.favoriteButtonPressed(at: sender, annotation: annotation)
    }
    
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
    
    private var adultCountLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = UIColor(red: 0.14, green: 0.80, blue: 0.46, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.text = "成人：-"
        $0.textAlignment = .center
    }
    
    private var childCountLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = UIColor(red: 0.14, green: 0.80, blue: 0.46, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.text = "兒童：-"
        $0.textAlignment = .center
    }
    
    init(annotation: MKAnnotation, isFavorite: Bool) {
        self.annotation = annotation as? FaceMaskAnnotation
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.setViews()
        self.updateContents(for: self.annotation)
        self.favoriteButton.isSelected = isFavorite
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setViews() {
        self.addSubview(favoriteButton)
        self.addSubview(nameLabel)
        self.addSubview(addressLabel)
        self.addSubview(phoneLabel)
        self.addSubview(adultCountLabel)
        self.addSubview(childCountLabel)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        self.favoriteButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(self.nameLabel)
            make.width.height.equalTo(24)
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
        
        self.adultCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.phoneLabel.snp.bottom).offset(16)
            make.right.equalTo(self.snp.centerX).offset(-4)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(30)
        }
        
        self.childCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(4)
            make.top.bottom.equalTo(self.adultCountLabel)
            make.right.equalTo(self.nameLabel)
        }
    }
    
    private func updateContents(for annotation: FaceMaskAnnotation?) {
        self.nameLabel.text = annotation?.propertie?.name
        self.addressLabel.text = annotation?.propertie?.address
        self.phoneLabel.text = annotation?.propertie?.phone
        self.adultCountLabel.text = "成人：\(annotation?.propertie?.adult ?? 0)"
        self.childCountLabel.text = "兒童：\(annotation?.propertie?.child ?? 0)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
