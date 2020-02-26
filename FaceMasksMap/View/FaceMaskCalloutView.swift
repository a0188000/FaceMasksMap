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
    func favoriteButtonPressed(at button: UIButton, buttonType type: FaceMaskCalloutView.ButtonType, annotation: FaceMaskAnnotation?)
}

extension FaceMaskCalloutView {
    enum ButtonType {
        case favorite, navigation, phoneCall
    }
}

class FaceMaskCalloutView: UIView {

    weak var delegate: FaceMasksCalloutViewDelegate?
    
    var annotation: FaceMaskAnnotation?
    
    private lazy var favoriteButton = UIButton {
        $0.setImage(UIImage(named: "favorite"), for: .normal)
        $0.setImage(UIImage(named: "favorite-highlight"), for: .selected)
        $0.addTarget(self, action: #selector(self.featureButtonPressed(_:)), for: .touchUpInside)
    }
    
    private lazy var navigationButton = UIButton {
        $0.setImage(UIImage(named: "naivgation-arrow"), for: .normal)
        $0.addTarget(self, action: #selector(self.featureButtonPressed(_:)), for: .touchUpInside)
    }
    
    private lazy var phoneCallButton = UIButton {
        $0.setImage(UIImage(named: "phone-call"), for: .normal)
        $0.addTarget(self, action: #selector(self.featureButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc private func featureButtonPressed(_ sender: UIButton) {
        var type: ButtonType = .favorite
        switch sender {
        case self.favoriteButton:     type = .favorite
        case self.navigationButton:   type = .navigation
        case self.phoneCallButton:    type = .phoneCall
        default: return
        }
        self.delegate?.favoriteButtonPressed(at: sender, buttonType: type, annotation: annotation)
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
        if #available(iOS 11.0, *) {
            self.backgroundColor = UIColor(named: "CalloutView_BG")
        } else {
            self.backgroundColor = .white
        }
//        self.layer.cornerRadius = 8
//        self.clipsToBounds = true
        self.setViews()
        self.updateContents(for: self.annotation)
        self.favoriteButton.isSelected = isFavorite
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawLineLayer()
        self.subviews.forEach { $0.layer.zPosition = 1 }
    }
    
    private func setViews() {
        self.addSubview(favoriteButton)
        self.addSubview(nameLabel)
        self.addSubview(addressLabel)
        self.addSubview(phoneLabel)
        self.addSubview(navigationButton)
        self.addSubview(phoneCallButton)
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
        
        self.navigationButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.phoneLabel.snp.bottom).offset(16)
            make.width.height.equalTo(32)
        }
        
        self.phoneCallButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.navigationButton.snp.right).offset(12)
            make.centerY.equalTo(self.navigationButton)
            make.width.height.equalTo(self.navigationButton)
        }
        
        self.adultCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.navigationButton.snp.bottom).offset(8)
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
    
    private func drawLineLayer() {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let minX = bounds.minX
        let maxX = bounds.maxX
        let minY = bounds.minY
        let maxY = bounds.maxY
        let radius: CGFloat = 8
        let pi: CGFloat = .pi
        let midX = bounds.midX
        
        let bezierPath = UIBezierPath {
            $0.move(to: .init(x: minX + radius, y: minY))
            $0.addLine(to: .init(x: maxX - radius, y: minY))
            // 右上圓
            $0.addArc(withCenter: .init(x: width - radius, y: radius), radius: radius, startAngle: -(pi / 2), endAngle: 0, clockwise: true)
            $0.addLine(to: .init(x: maxX, y: maxY - radius))
            // 右下園
            $0.addArc(withCenter: .init(x: width - radius, y: height - radius), radius: radius, startAngle: 0, endAngle: pi / 2, clockwise: true)
            $0.addLine(to: .init(x: midX + 12, y: maxY))
            // 中間箭頭
            $0.addQuadCurve(to: .init(x: midX, y: maxY + 14), controlPoint: .init(x: midX + 6, y: maxY))
            $0.addQuadCurve(to: .init(x: midX - 12, y: maxY), controlPoint: .init(x: midX - 6, y: maxY + 2))
            $0.addLine(to: .init(x: minX + radius, y: maxY))
            // 左下圓
            $0.addArc(withCenter: .init(x: minX + radius, y: maxY - radius), radius: radius, startAngle: pi / 2, endAngle: pi, clockwise: true)
            $0.addLine(to: .init(x: minX, y: minY + radius))
            // 左上圓
            $0.addArc(withCenter: .init(x: minX + radius, y: minY + radius), radius: radius, startAngle: pi, endAngle: pi * 1.5, clockwise: true)
            $0.close()
        }
        let shapeLayer = CAShapeLayer {
            $0.path = bezierPath.cgPath
            $0.lineWidth = 2
            $0.strokeColor = UIColor.black.cgColor
            if #available(iOS 11, *) {
                $0.fillColor = UIColor(named: "CalloutView_BG")?.cgColor
            } else {
                $0.fillColor = UIColor.white.cgColor
            }
            $0.zPosition = 0
        }
        self.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
