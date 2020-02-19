//
//  FavoritePharmacyCellTableViewCell.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/17.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

class FavoritePharmacyCellTableViewCell: UITableViewCell {

    private var nameLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private var adultCountLabel = UILabel {
        $0.font = .systemFont(ofSize: 18)
        $0.text = "成人：-"
    }
    
    private var childCountLabel = UILabel {
        $0.font = .systemFont(ofSize: 18)
        $0.text = "兒童：-"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setViews()
    }
    
    private func setViews() {
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(adultCountLabel)
        self.contentView.addSubview(childCountLabel)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        self.adultCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(-20)
            make.centerY.equalTo(self.nameLabel)
            make.width.equalTo(100)
        }
        
        self.childCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.adultCountLabel.snp.right).offset(8)
            make.centerY.equalTo(self.adultCountLabel)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setContent(_ pharmacy: RLM_Pharmacy) {
        self.nameLabel.text = pharmacy.name
        self.adultCountLabel.text = "成人：\(pharmacy.adult)"
        self.childCountLabel.text = "成人：\(pharmacy.child)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
