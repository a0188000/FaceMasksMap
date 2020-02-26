//
//  PharmacyCell.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/19.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

class PharmacyCell: UITableViewCell {
    
    private var nameLabel = UILabel {
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private var adultLabel = UILabel {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "成人：999"
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private var childLabel = UILabel {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "兒童：999"
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setViews()
    }
    
    private func setViews() {
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(adultLabel)
        self.contentView.addSubview(childLabel)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.right.equalTo(self.snp.centerX).offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.adultLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        self.childLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.adultLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setContent(pharmacy: Pharmacy) {
        self.nameLabel.text = pharmacy.name
        self.adultLabel.text = "成人：\(pharmacy.adult)"
        self.childLabel.text = "兒童：\(pharmacy.child)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
